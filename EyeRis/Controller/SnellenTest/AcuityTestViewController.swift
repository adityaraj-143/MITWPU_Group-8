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
    
    //    @IBOutlet weak var RecordingStatus: UILabel!
    @IBOutlet weak var SnellenImg: UIImageView!
    @IBOutlet weak var TextField: UITextField!
    @IBOutlet weak var micImage: UIImageView!
    
    @IBOutlet weak var inputContainerView: UIView!
    
    
    var silenceTimer: Timer?
    var didShowSilencePopup = false
    
    let speechRecognizer = SFSpeechRecognizer(
        locale: Locale(identifier: "en-US")
    )
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    let audioEngine = AVAudioEngine()
    var Recording = false
    
    var capturedTexts: [String] = []
    var currentSpeechBuffer = ""
    
    let totalImages = 7
    var currentImageIndex = 0  // starts at Image
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBubble()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        TextField.layer.cornerRadius = TextField.frame.height / 2
        TextField.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        SnellenImg.image = UIImage(named: "Image")
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
                    print("🎙️ Final text:", spokenText)
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
        startSilenceTimer()
    }
    
    func stopListening() {
        silenceTimer?.invalidate()
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        Recording = false
        
        //        DispatchQueue.main.async {
        //            self.RecordingStatus.text = "Not Recording"
        //            self.RecordingStatus.textColor = .systemGray
        //        }
    }
    
    //    func restartRecognitionSession() {
    //        recognitionTask?.cancel()
    //        recognitionTask = nil
    //
    //        recognitionRequest?.endAudio()
    //        recognitionRequest = nil
    //
    //        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    //        recognitionRequest?.shouldReportPartialResults = true
    //
    //        guard let recognitionRequest = recognitionRequest else { return }
    //
    //        recognitionTask = speechRecognizer?.recognitionTask(
    //            with: recognitionRequest
    //        ) { result, error in
    //            if let result = result {
    //                let spokenText = result.bestTranscription.formattedString
    //                let normalized = spokenText
    //                    .uppercased()
    //                    .trimmingCharacters(in: .whitespacesAndNewlines)
    //
    //                DispatchQueue.main.async {
    //                    self.TextField.text = spokenText
    //
    //                    if normalized.hasSuffix("NEXT") {
    //                        self.next()
    //                    }
    //                }
    //            }
    //        }
    //
    //        print("🔄 Recognition restarted (mic still running)")
    //    }
    
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
                print("📦 Stored chunk:", cleaned)
            }
        }
        
        stopListening()
        
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        currentSpeechBuffer = ""
        TextField.text = ""
        
        currentImageIndex += 1
        if currentImageIndex > totalImages {
            currentImageIndex = 1
        }
        
        let imageName = "Image \(currentImageIndex)"
        SnellenImg.image = UIImage(named: imageName)
        
        print("🖼️ Showing:", imageName)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.startListening()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        if audioEngine.isRunning {
            startSilenceTimer()
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
            print("📦 Stored text:", currentText)
        }
        
        // Clear the text field
        TextField.text = ""
        currentSpeechBuffer = ""
        
        // Move to next image
        currentImageIndex += 1
        if currentImageIndex > totalImages {
            // All images completed - you can show results or reset
            currentImageIndex = 1
            
            // Optional: Show all captured texts
            print("✅ All captured texts:", capturedTexts)
            
            // You might want to show a completion alert or navigate to results
            showCompletionAlert()
            return
        }
        
        // Update the image
        let imageName = "Image \(currentImageIndex)"
        SnellenImg.image = UIImage(named: imageName)
        print("🖼️ Showing:", imageName)
        
        // Restart recording if it was active
        if Recording {
            stopListening()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.startListening()
            }
        }
    }
    
    func showCompletionAlert() {
        let alert = UIAlertController(
            title: "Test Complete",
            message:
                "You've completed all \(totalImages) images. Captured \(capturedTexts.count) responses.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "View Results", style: .default) { _ in
                // Navigate to results page or show results
                print("All results:", self.capturedTexts)
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Start Over", style: .default) { _ in
                self.capturedTexts.removeAll()
                self.currentImageIndex = 0
                self.SnellenImg.image = UIImage(named: "Image")
            }
        )
        
        present(alert, animated: true)
    }
    @IBAction func MicBtn(_ sender: UIButton) {
        print("button Pressed")
        if audioEngine.isRunning {
            stopListening()
        } else {
            startListening()
        }
    }
    
    func showSilencePopup() {
        if didShowSilencePopup { return }
        didShowSilencePopup = true
        
        let alert = UIAlertController(
            title: "Tip",
            message:
                "Say out the letters loud followed by \"next\" once you are done",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert, animated: true)
    }
    
    func startSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(
            withTimeInterval: 2.0,
            repeats: false
        ) { _ in
            self.showSilencePopup()
        }
    }
    
    func resetSilenceTimer() {
        silenceTimer?.invalidate()
        startSilenceTimer()
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
}
