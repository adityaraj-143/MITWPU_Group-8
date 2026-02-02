//
//  PauseModalViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 23/01/26.
//

import UIKit

enum PauseReason {
    case manual
    case tooClose
    case tooFar
    case noFace
}

class PauseModalViewController: UIViewController {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var cameraContainer: UIView!
    @IBOutlet weak var cameraFeedBorderView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var resumeButton: UIButton!

    var pauseReason: PauseReason = .manual
    var exercise: Exercise!

    private var monitorTimer: Timer?
    var onResume: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attachCamera()
        startMonitoring()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layoutIfNeeded()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        monitorTimer?.invalidate()
        monitorTimer = nil
    }
    
    private func updateUI(){
        let camera = CameraManager.shared

        guard camera.isFaceDetected else {
            return
        }
        
        let distance = camera.currentDistance
        distanceLabel.text = "\(distance) cm"

        let isInRange = distance >= 37 && distance <= 45

        distanceLabel.textColor = isInRange ? .systemGreen : .systemRed
        
        let borderColor = isInRange ? UIColor.systemGreen : UIColor.systemRed
        UIView.animate(withDuration: 0.3) {
            self.cameraFeedBorderView.layer.borderColor = borderColor.cgColor
        }
    }
    private func attachCamera() {
        CameraManager.shared.attachPreview(to: cameraContainer)
        cameraFeedBorderView.layer.cornerRadius = 17
        cameraFeedBorderView.layer.borderWidth = 2
        cameraFeedBorderView.layer.borderColor = UIColor.systemRed.cgColor
        cameraFeedBorderView.clipsToBounds = true
        
        cameraContainer.layer.cornerRadius = 17
        cameraFeedBorderView.clipsToBounds = true
    }

    private func startMonitoring() {
        monitorTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            self?.checkAlignment()
            self?.updateUI()
        }
    }

    private func checkAlignment() {
        let state = CameraManager.shared.alignmentState

        if state == .manual {
            resumeButton.isEnabled = true
            resumeButton.alpha = 1.0
        } else {
            updateWarningText(for: state)
            resumeButton.isEnabled = false
            resumeButton.alpha = 0.5
        }
    }

    private func updateWarningText(for state: CameraAlignmentState) {
        switch state {
        case .tooClose:
            warningLabel.text = "You moved too close to the screen"
        case .tooFar:
            warningLabel.text = "You moved too far away from the screen"
        case .noFace:
            warningLabel.text = "Face not detected"
        case .manual:
            break
        }
    }

    @IBAction func resumeTapped(_ sender: UIButton) {
        monitorTimer?.invalidate()
        navigationController?.popViewController(animated: true)
        onResume?()
    }
}
