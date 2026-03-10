import UIKit
import ARKit
import RealityKit

#if targetEnvironment(simulator)
private let isSimulator = true
#else
private let isSimulator = false
#endif


class CalibrationViewController: UIViewController {
    
    var source: TestFlowSource?
    private var currentDistance: Int = 0
    private var arSession: ARSession?
    private var arView: ARView?
    private var updateTimer: Timer?
    private let minDistance: Int = 37
    private let maxDistance: Int = 45
    var exercise: Exercise?
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cameraFeedBorderView: UIView!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var cameraContainer: UIView!
    @IBOutlet weak var eyeInstruction: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBorderView()
        setupARView()
        if isSimulator {
            simulateDistance()
        } else {
            setupARKit()
        }
        
        configureEyeInstruction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSimulator { return }
        
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = false
        arSession?.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arSession?.pause()
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    // MARK: Setup
    private func setupBorderView() {
        cameraFeedBorderView.layer.cornerRadius = 17
        cameraFeedBorderView.layer.borderWidth = 5
        cameraFeedBorderView.layer.borderColor = UIColor.systemRed.cgColor
        cameraFeedBorderView.clipsToBounds = true
        
        cameraContainer.layer.cornerRadius = 17
        cameraFeedBorderView.clipsToBounds = true
    }
    
    private func setupARView() {
        let arView = ARView(frame: cameraContainer.bounds)
        self.arView = arView
        cameraContainer.addSubview(arView)
        
        arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: cameraContainer.topAnchor),
            arView.bottomAnchor.constraint(equalTo: cameraContainer.bottomAnchor),
            arView.leadingAnchor.constraint(equalTo: cameraContainer.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: cameraContainer.trailingAnchor)
        ])
    }
    
    private func setupARKit() {
        if isSimulator { return }
        
        guard ARFaceTrackingConfiguration.isSupported else {
            showARNotSupportedAlert()
            return
        }
        
        arSession = ARSession()
        arSession?.delegate = self
        arView?.session = arSession!
        
        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = false
        arSession?.run(config)
        
        startDistanceUpdates()
    }
    
    // MARK: - UI / Configuration
    private func configureEyeInstruction() {
        guard let source else {
            eyeInstruction.isHidden = true
            return
        }
        
        switch source {
        case .NVALeft, .DVALeft:
            eyeInstruction.isHidden = false
            eyeInstruction.text = "This is a test for your left eye.\nPlease close your right eye."
            
        case .NVARight, .DVARight:
            eyeInstruction.isHidden = false
            eyeInstruction.text = "This is a test for your right eye.\nPlease close your left eye."
            
        case .blinkRateTest, .todaysSet:
            eyeInstruction.isHidden = true
        }
    }
    
    
    // MARK: Distance Detection
    private func startDistanceUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateDistanceMeasurement()
        }
    }
    
    private func updateDistanceMeasurement() {
        if isSimulator { return }
        
        guard let frame = arSession?.currentFrame else { return }
        
        let faceAnchors = frame.anchors.compactMap { $0 as? ARFaceAnchor }
        
        if let faceAnchor = faceAnchors.first {
            let z = faceAnchor.transform.columns.3.z
            let distanceInMeters = abs(z)
            currentDistance = Int(distanceInMeters * 100)
            
            currentDistance = max(20, min(100, currentDistance))
            updateUI()
        } else {
            currentDistance = 0
            statusLabel.text = "No face detected"
            statusLabel.textColor = .systemRed
            proceedButton.isEnabled = false
            proceedButton.alpha = 0.5
            cameraFeedBorderView.layer.borderColor = UIColor.systemRed.cgColor
        }
    }
    
    private func updateUI() {
        distanceLabel.text = "\(currentDistance)cm"
        
        let isInRange = currentDistance >= minDistance && currentDistance <= maxDistance
        
        distanceLabel.textColor = isInRange ? .systemGreen : .systemRed
        
        if currentDistance < minDistance {
            statusLabel.text = "Move device away"
            statusLabel.textColor = .systemRed
        } else if currentDistance > maxDistance {
            statusLabel.text = "Move device closer"
            statusLabel.textColor = .systemRed
        } else {
            statusLabel.text = "Perfect distance!"
            statusLabel.textColor = .systemGreen
        }
        
        let borderColor = isInRange ? UIColor.systemGreen : UIColor.systemRed
        UIView.animate(withDuration: 0.3) {
            self.cameraFeedBorderView.layer.borderColor = borderColor.cgColor
        }
        proceedButton.isEnabled = true
        proceedButton.alpha = 1.0
        
    }
    
    // MARK: - Simulator
    private func simulateDistance() {
        currentDistance = 40   // perfect distance
        distanceLabel.text = "\(currentDistance)cm"
        statusLabel.text = "Simulator Mode"
        statusLabel.textColor = .systemGreen
        cameraFeedBorderView.layer.borderColor = UIColor.systemGreen.cgColor
        proceedButton.isEnabled = true
        proceedButton.alpha = 1.0
    }
    
    // MARK: Actions
    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        navigateBasedOnSource()
    }
    
    // MARK: - Alerts
    private func showARNotSupportedAlert() {
        let alert = UIAlertController(
            title: "AR Not Supported",
            message: "Device doesn't support face tracking.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: AR Session Delegate

extension CalibrationViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR error: \(error)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("AR interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("AR resumed")
    }
}

extension CalibrationViewController {
    
    func navigateBasedOnSource() {
        guard let source else { return }
        
        switch source {
        case .NVALeft:
            navigate(to: "AcuityTest", with: "AcuityTestViewController", source: source)
        case .NVARight:
            navigate(to: "AcuityTest", with: "AcuityTestViewController", source: source)
        case .DVALeft:
            navigate(to: "AcuityTest", with: "AcuityTestViewController", source: source)
        case .DVARight:
            navigate(to: "AcuityTest", with: "AcuityTestViewController", source: source)
        case .blinkRateTest ,.todaysSet:
            navigate(to: "BlinkRateTest", with: "BlinkRateTestViewController", source: source)
        }
    }
    
    private func navigate(to storyboardName: String, with identifier: String, source: TestFlowSource) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
        if let vc = vc as? AcuityTestViewController {
            vc.source = source
        }
        
        if let vc = vc as? BlinkRateViewController {
            vc.source = source
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

