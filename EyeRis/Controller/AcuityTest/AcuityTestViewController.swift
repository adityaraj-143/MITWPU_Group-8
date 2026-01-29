//
//  Chart1ViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 15/12/25.
//

import Speech
import UIKit

class AcuityTestViewController: UIViewController, UITextFieldDelegate, UIAdaptivePresentationControllerDelegate {
    var source: TestFlowSource?
    var nextNav = ""
    var nextNavId = ""
    
    var expectedTexts: [String] = []

    var silenceTimer: Timer?
    
    let speechRecognizer = SFSpeechRecognizer(
        locale: Locale(identifier: "en-US")
    )
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    let audioEngine = AVAudioEngine()
    var Recording = false
    
    var capturedTexts: [String] = []
    var currentSpeechBuffer = ""
    
    
    var currentLevel = 0
    
    @IBOutlet weak var TextField: UITextField!
    @IBOutlet weak var micImage: UIImageView!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var snellenLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBubble()
        startListening()
        
        switch source {
        case .NVALeft:
            nextNav = "CalibrationScreen"
            nextNavId = "CalibrationViewController"
        case .NVARight:
            nextNav = "TestInstructions"
            nextNavId = "TestInstructionsViewController"
        case .DVALeft:
            nextNav = "CalibrationScreen"
            nextNavId = "CalibrationViewController"
        case .DVARight:
            nextNav = "Completion"
            nextNavId = "CompletionViewController"
        case .blinkRateTest:
            break;
        case nil:
            assertionFailure("source was not set")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        TextField.borderStyle = .none
        TextField.backgroundColor = .white
        TextField.layer.borderWidth = 1
        TextField.layer.borderColor = UIColor.systemGray4.cgColor
        TextField.leftView = UIView(
            frame: CGRect(x: 0, y: 0, width: 12, height: 0)
        )
        TextField.leftViewMode = .always
        
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status != .authorized {
                    print("Speech recognition not authorized")
                }
            }
        }
        
        TextField.delegate = self
        
        currentLevel = 0
        updateSnellenLabel()
        
    }
    
    func updateSnellenLabel() {
        let letterCount = currentLevel + 1
        let text = generateRandomLetters(count: letterCount)
        
        snellenLabel.text = text
        snellenLabel.font = UIFont.systemFont(
            ofSize: fontSizes[currentLevel],
            weight: .bold
        )
        
        expectedTexts.append(text)

        
        print("Level:", currentLevel + 1,
              "Text:", text,
              "Font:", fontSizes[currentLevel])
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if currentLevel >= fontSizes.count - 1 {
            navigationController?.popViewController(animated: true)
            return
        }
        
        let alert = UIAlertController(
            title: "Quit Test?",
            message: "Your test is not completed yet. Do you want to stop?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Restart", style: .default) { _ in
            self.restartTest()
        })
        
        alert.addAction(UIAlertAction(title: "Stop", style: .destructive) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alert, animated: true)
        
    }
    
    func restartTest() {
        stopListening()
        
        capturedTexts.removeAll()
        expectedTexts.removeAll()
        currentSpeechBuffer = ""
        currentLevel = 0
        
        updateSnellenLabel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.startListening()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        TextField.layer.cornerRadius = TextField.frame.height / 2
        TextField.layer.masksToBounds = true
    }
    
    
    func showBubble() {
        let bubble = SpeechBubbleView(
            text: "Say the letters and then say NEXT"
        )
        
        let width: CGFloat = 180
        let height: CGFloat = 65
        bubble.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        // Get mic position in screen coords
        let micFrame = micImage.convert(micImage.bounds, to: view)
        
        // Position bubble above mic
        bubble.center = CGPoint(
            x: micFrame.midX,
            y: micFrame.minY - height/2 - 8
        )
        
        view.addSubview(bubble)
        
        // Auto remove
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            bubble.removeFromSuperview()
        }
    }
    
    func adaptivePresentationStyle(
        for controller: UIPresentationController
    ) -> UIModalPresentationStyle {
        return .none
    }
    
    // ONLY CHANGE: stop audio when leaving page
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListening()
    }
    
    func startListening() {
        view.endEditing(true)
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        Recording = true
        
        //        DispatchQueue.main.async {
        //            self.RecordingStatus.text = "Recording Audio"
        //            self.RecordingStatus.textColor = .systemGreen
        //        }
        
        print("recording started")
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(
            .record,
            mode: .measurement,
            options: .duckOthers
        )
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(
            with: recognitionRequest
        ) { result, error in
            if let result = result {
                self.resetSilenceTimer()
                
                let spokenText = result.bestTranscription.formattedString
                let normalized =
                spokenText
                    .uppercased()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                DispatchQueue.main.async {
                    print("Final text:", spokenText)
                    self.currentSpeechBuffer = spokenText
                    self.TextField.text = spokenText
                    
                    if normalized.contains("NEXT") {
                        self.next()
                        print("text detected")
                    }
                }
            }
            
            if error != nil || (result?.isFinal ?? false) {
                self.stopListening()
            }
        }
        
        inputNode.removeTap(onBus: 0)
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: recordingFormat
        ) {
            buffer,
            _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        //        startSilenceTimer()
    }
    
    func stopListening() {
        silenceTimer?.invalidate()
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        Recording = false
        
    }
    
    func next() {
        print("next is called")
        
        if !currentSpeechBuffer.isEmpty {
            let cleaned =
            currentSpeechBuffer
                .replacingOccurrences(
                    of: "\\bnext\\b",
                    with: "",
                    options: [.regularExpression, .caseInsensitive]
                )
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !cleaned.isEmpty {
                capturedTexts.append(cleaned)
                print("Stored chunk:", cleaned)
            }
        }
        
        stopListening()
        
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        currentSpeechBuffer = ""
        TextField.text = ""
        currentLevel += 1
        
        if currentLevel >= fontSizes.count {
            finishTestAndStoreResult()
            navigate()
            return
        }
        
        updateSnellenLabel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.startListening()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        if audioEngine.isRunning {
            //            startSilenceTimer()
        }
    }
    
    @IBAction func NextBtn(_ sender: UIButton) {
        // Dismiss keyboard if it's open
        view.endEditing(true)
        
        // Capture the current text from the text field if it's not empty
        let currentText =
        TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        ?? ""
        
        if !currentText.isEmpty {
            capturedTexts.append(currentText)
            print("Stored text:", currentText)
        }
        TextField.text = ""
        currentSpeechBuffer = ""
        
        currentLevel += 1
        if currentLevel >= fontSizes.count {
            // All images completed - you can show results or reset
            
            currentLevel = 1
            
            print("All captured texts:", capturedTexts)
            finishTestAndStoreResult()
            navigate()
            return
        }
        
        updateSnellenLabel()
        
        // Restart recording if it was active
        if Recording {
            stopListening()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.startListening()
            }
        }
    }
    
    //    @IBAction func MicBtn(_ sender: UIButton) {
    //        print("button Pressed")
    //        if audioEngine.isRunning {
    //            stopListening()
    //        } else {
    //            startListening()
    //        }
    //    }
    //
    
    func resetSilenceTimer() {
        silenceTimer?.invalidate()
        //        startSilenceTimer()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        stopListening()
        silenceTimer?.invalidate()
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        let moveUp = frame.height - view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration) {
            self.inputContainerView.transform = CGAffineTransform(
                translationX: 0,
                y: -moveUp
            )
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        UIView.animate(withDuration: duration) {
            self.inputContainerView.transform = .identity
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func navigate() {
        let storyboard = UIStoryboard(name: nextNav, bundle: nil)
        
        let vc = storyboard.instantiateViewController(
            withIdentifier: nextNavId
        )
        
        switch source {
        case .NVALeft:
            if let tempVC = vc as? CalibrationViewController {
                tempVC.source = .NVARight
            }
        case .NVARight:
            if let tempVC = vc as? TestInstructionsViewController {
                tempVC.source = .DVALeft
            }
        case .DVALeft:
            if let tempVC = vc as? CalibrationViewController {
                tempVC.source = .DVARight
            }
        case .DVARight:
            if let tempVC = vc as? CompletionViewController {
                tempVC.source = .acuityTest
            }
        default:
            break
        }
        

        if let testVC = vc as? TestInstructionsViewController {
            testVC.source = source
        }

        navigationController?.pushViewController(vc, animated: true)
    }
    
    func finishTestAndStoreResult() {
        let bestLevel = getBestCorrectLevel(
            expectedTexts: expectedTexts,
            spokenTexts: capturedTexts
        ) ?? 0

        let score = calcAcuityScore(level: bestLevel)
        let today = Calendar.current.startOfDay(for: Date())

        let result = AcuityTestResult(
            id: Int.random(in: 1000...9999),
            testType: (source == .NVALeft || source == .NVARight) ? .NearVision : .DistantVision,
            testDate: today,
            heathyScore: "20/20",
            leftEyeScore: (source == .NVALeft || source == .DVALeft) ? score : "",
            rightEyeScore: (source == .NVARight || source == .DVARight) ? score : "",
            comment: "Auto generated"
        )
        print("acuity page result: ", result)

        AcuityTestResultResponse.shared.results.append(result)

        print("Stored result:", result)
    }


}
