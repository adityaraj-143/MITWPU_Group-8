//
//  ExerciseCalibrationViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 23/01/26.
//

import UIKit

class ExerciseCalibrationViewController: UIViewController {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cameraContainer: UIView!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var cameraFeedBorderView: UIView!

    // Passed from previous screen
    var exercise: Exercise?
    var inTodaySet: Int? = 0

    private var updateTimer: Timer?
    private let minDistance = 37
    private let maxDistance = 45

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraFeedBorderView.layer.cornerRadius = 17
        cameraFeedBorderView.layer.borderWidth = 2
        cameraFeedBorderView.layer.borderColor = UIColor.systemRed.cgColor
        cameraFeedBorderView.clipsToBounds = true

        cameraContainer.layer.cornerRadius = 17
        cameraContainer.clipsToBounds = true

        proceedButton.isEnabled = false
        proceedButton.alpha = 0.5

        CameraManager.shared.configure()
        CameraManager.shared.attachPreview(to: cameraContainer)
        CameraManager.shared.start()

        updateTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            self?.updateUI()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            CameraManager.shared.stop()
        }
    }

    @IBAction func proceedButtonTapped(_ sender: UIButton) {

        let referenceDistance = CameraManager.shared.currentDistance

        guard let exercise else {
            assertionFailure("Exercise missing during calibration")
            return
        }

        // Start the session
        ExerciseSessionManager.shared.start(
            exercise: exercise,
            referenceDistance: referenceDistance,
            time: 20       // or pass real duration if you have it
        )

        navigateToExercise()
    }

    private func updateUI() {
        let camera = CameraManager.shared

        guard camera.isFaceDetected else {
            distanceLabel.text = "--"
            statusLabel.text = "No face detected"
            statusLabel.textColor = .systemRed
            proceedButton.isEnabled = false
            proceedButton.alpha = 0.5
            cameraFeedBorderView.layer.borderColor = UIColor.systemRed.cgColor
            return
        }

        let distance = camera.currentDistance
        distanceLabel.text = "\(distance) cm"

        let isInRange = distance >= minDistance && distance <= maxDistance
        distanceLabel.textColor = isInRange ? .systemGreen : .systemRed

        if distance < minDistance {
            statusLabel.text = "Move device away"
            statusLabel.textColor = .systemRed
        } else if distance > maxDistance {
            statusLabel.text = "Move device closer"
            statusLabel.textColor = .systemRed
        } else {
            statusLabel.text = "Perfect distance!"
            statusLabel.textColor = .systemGreen
        }

        let borderColor = isInRange ? UIColor.systemGreen : UIColor.systemRed
        UIView.animate(withDuration: 0.25) {
            self.cameraFeedBorderView.layer.borderColor = borderColor.cgColor
        }

        proceedButton.isEnabled = isInRange
        proceedButton.alpha = isInRange ? 1.0 : 0.5
    }

    deinit {
        updateTimer?.invalidate()
    }

    // MARK: - Navigation to exercise screen (dynamic)

    private func navigateToExercise() {

        guard let exercise = ExerciseSessionManager.shared.exercise else {
            assertionFailure("Exercise missing in session manager")
            return
        }

        let storyboard = UIStoryboard(
            name: exercise.getStoryboardName(),
            bundle: nil
        )

        let identifier = exercise.getStoryboardID()

        let vc = storyboard.instantiateViewController(
            withIdentifier: identifier
        )

        // Universal downcast through protocol
        if let exerciseVC = vc as? ExerciseFlowHandling {
            exerciseVC.exercise = exercise
            exerciseVC.inTodaySet = inTodaySet
        } else {
            assertionFailure("ViewController does not conform to ExerciseFlowHandling")
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}
