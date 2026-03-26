//
//  AcuityTestViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 15/12/25.
//

import Speech
import UIKit

class AcuityTestViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var source: TestFlowSource?
    
    private var nextNav = ""
    private var nextNavId = ""
    private var expectedTexts: [String] = []
    private var capturedTexts: [String] = []
    private var currentSpeechBuffer = ""
    private var currentLevel = 0
    
    // MARK: - Speech Recognition
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var isRecording = false
    
    // MARK: - Mic State Management
    
    private var pendingWorkItem: DispatchWorkItem?
    private var currentMicState = false
    private var lastLoudTime: Date = .distantPast
    private let silenceThreshold: TimeInterval = 0.4
    
    // MARK: - Outlets
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var micImage: UIImageView!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var snellenLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        requestSpeechAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureNavigation()
        showBubble()
        startListening()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListening()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textField.layer.cornerRadius = textField.frame.height / 2
        textField.layer.masksToBounds = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // TextField styling
        textField.delegate = self
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        
        updateSnellenLabel()
    }
    
    private func configureNavigation() {
        switch source {
        case .NVALeft:
            nextNav = "TestCalibration"
            nextNavId = "TestCalibrationViewController"
        case .NVARight:
            nextNav = "TestInstructions"
            nextNavId = "TestInstructionsViewController"
        case .DVALeft:
            nextNav = "TestCalibration"
            nextNavId = "TestCalibrationViewController"
        case .DVARight:
            nextNav = "TestCompletion"
            nextNavId = "TestCompletionViewController"
        case .blinkRateTest:
            break
        default:
            assertionFailure("Invalid source was set")
        }
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("Speech recognition not authorized")
            }
        }
    }
    
    // MARK: - Snellen Chart
    
    private func updateSnellenLabel() {
        let letterCount = currentLevel + 1
        let text = generateRandomLetters(count: letterCount)
        
        snellenLabel.text = text
        snellenLabel.font = .systemFont(ofSize: fontSizes[currentLevel], weight: .bold)
        expectedTexts.append(text)
        
        print("Level: \(currentLevel + 1), Text: \(text), Font: \(fontSizes[currentLevel])")
    }
    
    // MARK: - Speech Bubble
    
    private func showBubble() {
        let bubble = SpeechBubbleView(text: "Say the letters and then say NEXT")
        let size = CGSize(width: 180, height: 65)
        bubble.frame = CGRect(origin: .zero, size: size)
        
        let micFrame = micImage.convert(micImage.bounds, to: view)
        bubble.center = CGPoint(x: micFrame.midX, y: micFrame.minY - size.height / 2 - 8)
        
        view.addSubview(bubble)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            bubble.removeFromSuperview()
        }
    }
    
    // MARK: - Speech Recognition
    
    private func startListening() {
        view.endEditing(true)
        
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = true
        
        print("Recording started")
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Setup recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let spokenText = result.bestTranscription.formattedString
                
                DispatchQueue.main.async {
                    print("Transcription: \(spokenText)")
                    self.currentSpeechBuffer = spokenText
                    self.textField.text = spokenText
                    
                    if spokenText.uppercased().contains("NEXT") {
                        self.advanceToNextLevel()
                    }
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.stopListening()
            }
        }
        
        // Install audio tap
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            self?.updateMicState(from: buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    private func stopListening() {
        pendingWorkItem?.cancel()
        pendingWorkItem = nil
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        
        isRecording = false
        currentMicState = false
        lastLoudTime = .distantPast
        
        DispatchQueue.main.async {
            self.setMicIcon(active: false)
        }
    }
    
    // MARK: - Mic State
    
    private func updateMicState(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        let frameLength = Int(buffer.frameLength)
        var sum: Float = 0
        for i in 0..<frameLength {
            sum += channelData[i] * channelData[i]
        }
        
        let rms = sqrt(sum / Float(frameLength))
        let isLoud = rms > 0.01
        
        if isLoud {
            lastLoudTime = Date()
            pendingWorkItem?.cancel()
            pendingWorkItem = nil
            
            if !currentMicState {
                currentMicState = true
                DispatchQueue.main.async { self.setMicIcon(active: true) }
            }
        } else if currentMicState && pendingWorkItem == nil {
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                
                if Date().timeIntervalSince(self.lastLoudTime) >= self.silenceThreshold {
                    self.currentMicState = false
                    self.pendingWorkItem = nil
                    DispatchQueue.main.async { self.setMicIcon(active: false) }
                } else {
                    self.pendingWorkItem = nil
                }
            }
            
            pendingWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + silenceThreshold, execute: workItem)
        }
    }
    
    private func setMicIcon(active: Bool) {
        micImage.image = UIImage(systemName: active ? "microphone.fill" : "microphone")
        micImage.tintColor = active ? .systemGreen : .systemBlue
    }
    
    // MARK: - Test Flow
    
    private func advanceToNextLevel() {
        print("Advancing to next level")
        
        // Store cleaned speech buffer
        if !currentSpeechBuffer.isEmpty {
            let cleaned = currentSpeechBuffer
                .replacingOccurrences(of: "\\bnext\\b", with: "", options: [.regularExpression, .caseInsensitive])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !cleaned.isEmpty {
                capturedTexts.append(cleaned)
                print("Stored chunk: \(cleaned)")
            }
        }
        
        stopListening()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        currentSpeechBuffer = ""
        textField.text = ""
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
    
    private func restartTest() {
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
    
    // MARK: - Actions
    
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
        alert.addAction(UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
            self?.restartTest()
        })
        alert.addAction(UIAlertAction(title: "Stop", style: .destructive) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        let currentText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !currentText.isEmpty {
            capturedTexts.append(currentText)
            print("Stored text: \(currentText)")
        }
        
        textField.text = ""
        currentSpeechBuffer = ""
        currentLevel += 1
        
        if currentLevel >= fontSizes.count {
            print("All captured texts: \(capturedTexts)")
            finishTestAndStoreResult()
            navigate()
            return
        }
        
        updateSnellenLabel()
        
        if isRecording {
            stopListening()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.startListening()
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        stopListening()
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardObservers() {
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
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo,
              let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        let moveUp = frame.height - view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration) {
            self.inputContainerView.transform = CGAffineTransform(translationX: 0, y: -moveUp)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let info = notification.userInfo,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        UIView.animate(withDuration: duration) {
            self.inputContainerView.transform = .identity
        }
    }
    
    // MARK: - Navigation
    
    private func navigate() {
        let storyboard = UIStoryboard(name: nextNav, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: nextNavId)
        
        switch source {
        case .NVALeft:
            (vc as? TestCalibrationViewController)?.source = .NVARight
        case .NVARight:
            (vc as? TestInstructionsViewController)?.source = .DVALeft
        case .DVALeft:
            (vc as? TestCalibrationViewController)?.source = .DVARight
        case .DVARight:
            (vc as? TestCompletionViewController)?.source = .acuityTest
        default:
            break
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Results
    
    private func finishTestAndStoreResult() {
        let bestLevel = getBestCorrectLevel(expectedTexts: expectedTexts, spokenTexts: capturedTexts) ?? 0
        let score = calcAcuityScore(level: bestLevel)
        let today = Calendar.current.startOfDay(for: Date())
        
        let isNearVision = source == .NVALeft || source == .NVARight
        let isLeftEye = source == .NVALeft || source == .DVALeft
        
        let result = AcuityTestResult(
            id: Int.random(in: 1000...9999),
            testType: isNearVision ? .nearVision : .distantVision,
            testDate: today,
            healthyScore: "20/20",
            leftEyeScore: isLeftEye ? score : "",
            rightEyeScore: isLeftEye ? "" : score,
            comment: "Auto generated"
        )
        
        AcuityTestResultStore().save(result)
        print("Stored result: \(result)")
    }
}
