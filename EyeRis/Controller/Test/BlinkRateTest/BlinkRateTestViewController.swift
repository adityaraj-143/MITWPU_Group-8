//
//  BlinkRateViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 26/11/25.
//


import UIKit
import ARKit
import AVFoundation

class BlinkRateTestViewController: UIViewController, ARSessionDelegate {
    
    // Invisible AR session
    let session = ARSession()
    var source: TestFlowSource?
    var flowMode: TestFlowMode?
    let blinkTest = BlinkRateTestStore.shared.test
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var Passage: UILabel!
    
    // Blink state variables
    var isBlinking = false
    var blinkCount = 0
    var timer: Timer?
    var timeRemaining: Int = 120
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Passage.text = blinkTest.passages
        timeRemaining = blinkTest.duration
        
        requestCameraPermission { granted in
            if granted {
                self.startFaceTracking()
                self.startTimer()
            } else {
                self.showPermissionAlert()
            }
        }
    }
    
    
    func startTimer() {
        let duration = blinkTest.duration
        timeRemaining = 10
        
        timerLabel.text = String(format: "%02d:%02d", duration / 60, duration % 60)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTimer()
        }
    }
    
    func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            
            let minutes = timeRemaining / 60
            let seconds = timeRemaining % 60
            
            timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        } else {
            timer?.invalidate()
            timer = nil
            
            // Stop the AR session
            session.pause()
            
            timerLabel.text = "00:00"
            
            let result = BlinkRateTestResult(
                id: Int.random(in: 1000...9999),
                blinks: blinkCount,
                duration: blinkTest.duration,
                performedOn: Date()
            )
            BlinkRateTestResultDataStore.shared.save(result)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                
                if(self.source == .blinkRateTest) {
                    self.navigateToTestCompletion(to: "TestCompletion", with: "TestCompletionViewController", source: .blinkRateTest)
                }
                else if (self.source == .todaysSet){
                    if(self.flowMode == .single) {
                        self.navigateToTestCompletion(to: "TestCompletion", with: "TestCompletionViewController", source: .blinkRateTest)
                    } else {
                        self.navigateToTodaysSetCompletion(to: "ExerciseCompletion", with: "ExerciseCompletionViewController", source: .todaysSet)
                    }
                }
                else {
                    print(self.source ?? "no source at all")
                    assertionFailure("Wrong source sent to blink rate test")
                }
            }
        }
        
    }
    
    
    // MARK: CAMERA PERMISSION
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
            
        case .authorized:
            completion(true)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
            
        case .denied:
            completion(false)
            
        case .restricted:
            completion(false)
            
        @unknown default:
            completion(false)
        }
    }
    
    func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Permission Needed",
            message: "Please enable camera access in Settings to use eye tracking.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: START FACE TRACKING
    func startFaceTracking() {
        
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking not supported on this device.")
            return
        }
        
        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = true
        
        session.delegate = self
        session.run(config, options: [])
    }
    
    // MARK: AR SESSION DELEGATE
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        
        let leftBlink  = faceAnchor.blendShapes[.eyeBlinkLeft]  as? Float ?? 0.0
        let rightBlink = faceAnchor.blendShapes[.eyeBlinkRight] as? Float ?? 0.0
        
        detectBlink(left: leftBlink, right: rightBlink)
    }
    
    // MARK: BLINK DETECTION
    func detectBlink(left: Float, right: Float) {
        
        let threshold: Float = 0.65
        let isClosed = (left > threshold && right > threshold)
        
        if isClosed && !isBlinking {
            isBlinking = true
        }
        
        if !isClosed && isBlinking {
            blinkCount += 1
            isBlinking = false
            print("\(blinkCount)")
            
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        let alert = UIAlertController(
            title: "End Blink Rate Test?",
            message: "Do you want to quit or restart the test?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Restart",
            style: .default,
            handler: { _ in
                self.resetTest()
            }
        ))
        
        alert.addAction(UIAlertAction(
            title: "Quit",
            style: .destructive,
            handler: { _ in
                self.session.pause()
                self.navigationController?.popToRootViewController(animated: true)
            }
        ))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)    }
    
    func resetTest() {
        timer?.invalidate()
        timer = nil
        session.pause()
        
        let duration = blinkTest.duration
        timeRemaining = duration
        blinkCount = 0
        isBlinking = false
        
        timerLabel.text = String(format: "%02d:%02d", duration / 60, duration % 60)
        
        startFaceTracking()
        startTimer()
    }
    
    func navigateToTestCompletion(
        to storyboardName: String,
        with identifier: String,
        source: TestSource? = nil
    ) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        let vc = storyboard.instantiateViewController(
            withIdentifier: identifier
        )
        
        if let completionVC = vc as? TestCompletionViewController {
            completionVC.source = source
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToTodaysSetCompletion(
        to storyboardName: String,
        with identifier: String,
        source: ExerciseSource? = nil
    ) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        let vc = storyboard.instantiateViewController(
            withIdentifier: identifier
        )
        
        if let completionVC = vc as? ExerciseCompletionViewController {
            completionVC.source = source
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
