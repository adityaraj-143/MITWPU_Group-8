//
//  Chart1ViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 15/12/25.
//

import Speech
import UIKit

class AcuityTestViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var RecordingStatus: UILabel!
    @IBOutlet weak var SnellenImg: UIImageView!
    @IBOutlet weak var TextField: UITextField!
    
    
    
    var silenceTimer: Timer?

    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?

    let audioEngine = AVAudioEngine()
    var Recording = false

    var capturedTexts: [String] = []
    var currentSpeechBuffer = ""

    let totalImages = 7
    var currentImageIndex = 0   // starts at Image

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        TextField.layer.cornerRadius = TextField.frame.height / 2
        TextField.layer.masksToBounds = true
    }

    override func viewDidLoad() {
        SnellenImg.image = UIImage(named: "Image")
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        TextField.borderStyle = .none
        TextField.backgroundColor = .white
        TextField.layer.borderWidth = 1
        TextField.layer.borderColor = UIColor.systemGray4.cgColor
        TextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        TextField.leftViewMode = .always

        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status != .authorized {
                    print("Speech recognition not authorized")
                }
            }
        }
        
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
        
        TextField.delegate = self

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

        DispatchQueue.main.async {
            self.RecordingStatus.text = "Recording Audio"
            self.RecordingStatus.textColor = .systemGreen
        }

        print("recording started")

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.resetSilenceTimer()
                
                let spokenText = result.bestTranscription.formattedString
                let normalized = spokenText
                    .uppercased()
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                DispatchQueue.main.async {
                    print("🎙️ Final text:", spokenText)
                    self.currentSpeechBuffer = spokenText
                    self.TextField.text = spokenText

                    if normalized.hasSuffix("NEXT") {
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
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            buffer, _ in
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

        DispatchQueue.main.async {
            self.RecordingStatus.text = "Not Recording"
            self.RecordingStatus.textColor = .systemGray
        }
    }

    func restartRecognitionSession() {
        recognitionTask?.cancel()
        recognitionTask = nil

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        guard let recognitionRequest = recognitionRequest else { return }

        recognitionTask = speechRecognizer?.recognitionTask(
            with: recognitionRequest
        ) { result, error in
            if let result = result {
                let spokenText = result.bestTranscription.formattedString
                let normalized = spokenText
                    .uppercased()
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                DispatchQueue.main.async {
                    self.TextField.text = spokenText

                    if normalized.hasSuffix("NEXT") {
                        self.next()
                    }
                }
            }
        }

        print("🔄 Recognition restarted (mic still running)")
    }

    func next() {
        print("next is called")

        if !currentSpeechBuffer.isEmpty {
            let cleaned = currentSpeechBuffer
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
    }

    @IBAction func NextBtn(_ sender: UIButton) {
        // i wanna store the text in the textfield somewhere and move to the nect screen
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
        let alert = UIAlertController(
            title: "Tip",
            message: "Say out the letters loud followed by \"next\" once you are done",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert, animated: true)
    }
    
    func startSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.showSilencePopup()
        }
    }

    func resetSilenceTimer() {
        silenceTimer?.invalidate()
        startSilenceTimer()
    }
    
    // MARK: Keyboards handlers
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame =
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height

        // Move view up only if textfield is hidden
        if view.frame.origin.y == 0 {
            view.frame.origin.y -= keyboardHeight / 2
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        stopListening()
    }
    
    



}
