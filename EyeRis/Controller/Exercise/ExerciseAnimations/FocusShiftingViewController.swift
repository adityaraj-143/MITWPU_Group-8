//
//  FocusShiftingViewController.swift
//  figure8_pattern
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class FocusShiftingViewController: UIViewController, ExerciseAlignmentMonitoring, ExerciseFlowHandling {

    @IBOutlet weak var timer_label: UILabel!
    var exercise: Exercise?
    var inTodaySet: Int? = 0
    
    var referenceDistance: Int = 40   // default fallback
    
    private let exerciseDuration = 10

    private let exerciseContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private var displayLink: CADisplayLink?
    private var coordinateTimer: Timer?
    
    // MARK: Properties
    private var focusDots: [FocusDot] = []
    private var currentRedIndex: Int?
    private var focusTimer: Timer?
    private let rows = 5
    private let columns = 5
    private let dotSize: CGFloat = 25
    private let containerHeight: CGFloat = 750
    private let focusInterval: TimeInterval = 1.5
    private let minimumFocusDistance: CGFloat = 120
    private let maxSelectionAttempts = 20

    private var monitorTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        setupExerciseContainer()
        setupFocusDots()

        startCountdownThenExercise {
            self.startFocusExercise()

            // Plug into session system
            ExerciseSessionManager.shared.onSessionCompleted = { [weak self] in
                self?.handleExerciseCompletion()
            }

            // Start timed session
            guard let exercise = self.exercise else {
                assertionFailure("Exercise not set in FocusShiftingViewController")
                return
            }

            ExerciseSessionManager.shared.start(
                exercise: exercise,
                referenceDistance: ExerciseSessionManager.shared.referenceDistance,
                time: self.exerciseDuration
            )
            self.startAlignmentMonitoring(timer: &self.monitorTimer)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // If pause modal is being shown, just stop monitoring
        if navigationController?.topViewController is PauseModalViewController {
            monitorTimer?.invalidate()
            monitorTimer = nil
            return
        }else {
            monitorTimer?.invalidate()
            monitorTimer = nil
            ExerciseSessionManager.shared.endSession(resetCamera: true)
        }
    }
    
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        stopAllTimers()
        
        monitorTimer?.invalidate()
        monitorTimer = nil
        
        // End exercise session (stops camera + resets state)
        ExerciseSessionManager.shared.endSession(resetCamera: true)
        
        // Pop directly to ExerciseList
        popToExerciseList()
    }
    
    private func stopAllTimers() {
        displayLink?.invalidate()
        displayLink = nil

        coordinateTimer?.invalidate()
        coordinateTimer = nil

        monitorTimer?.invalidate()
        monitorTimer = nil
    }
    
    private func popToExerciseList() {
        guard let navController = navigationController else { return }
        
        for vc in navController.viewControllers {
            if vc is ExerciseListViewController {
                navController.popToViewController(vc, animated: true)
                return
            }
        }
        
        // fallback (should not happen)
        navController.popToRootViewController(animated: true)
    }

    func showPause(reason: CameraAlignmentState) {
        
        // Prevent multiple pushes
        guard navigationController?.topViewController === self else { return }
        
        guard let exercise = ExerciseSessionManager.shared.exercise else { return }
        
        let storyboard = UIStoryboard(name: "ExercisePauseScreen", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "PauseModalViewController"
        ) as? PauseModalViewController else {
            return
        }
        
        vc.pauseReason = mapReason(reason)
        vc.exercise = exercise
        
        vc.onResume = { [weak self] in
            self?.startAlignmentMonitoring(timer: &self!.monitorTimer)
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func mapReason(_ state: CameraAlignmentState) -> PauseReason {
        switch state {
        case .tooClose: return .tooClose
        case .tooFar: return .tooFar
        case .noFace: return .noFace
        case .manual: return .manual // fallback
        }
    }

    // MARK: Setup
    private func setupExerciseContainer() {
        exerciseContainer.frame = CGRect(
            x: 0,
            y: (view.bounds.height - containerHeight) / 2,
            width: view.bounds.width,
            height: containerHeight
        )

        view.addSubview(exerciseContainer)
    }

    private func setupFocusDots() {
        focusDots.removeAll()

        let spacingX = exerciseContainer.bounds.width / CGFloat(columns + 1)
        let spacingY = exerciseContainer.bounds.height / CGFloat(rows + 1)

        for row in 1...rows {
            for column in 1...columns {
                let position = CGPoint(
                    x: spacingX * CGFloat(column),
                    y: spacingY * CGFloat(row)
                )

                let dotView = UIView(
                    frame: CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
                )

                dotView.center = position
                dotView.backgroundColor = .white
                dotView.layer.cornerRadius = dotSize / 2

                exerciseContainer.addSubview(dotView)
                focusDots.append(FocusDot(position: position, view: dotView))
            }
        }
    }

    // MARK: Countdown
    private func startCountdownThenExercise(startExercise: @escaping () -> Void) {
        var count = 3
        timer_label.isHidden = false
        timer_label.text = "\(count)"

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            count -= 1

            if count == 0 {
                timer.invalidate()
                self.timer_label.isHidden = true
                startExercise()
            } else {
                self.timer_label.text = "\(count)"
            }
        }
    }

    // MARK: Logic
    private func startFocusExercise() {
        focusTimer = Timer.scheduledTimer(
            withTimeInterval: focusInterval,
            repeats: true
        ) { [weak self] _ in
            self?.switchRedDot()
        }
    }

    private func switchRedDot() {
        resetPreviousRedDot()

        guard !focusDots.isEmpty else { return }

        let previousPosition = currentRedIndex != nil
            ? focusDots[currentRedIndex!].position
            : nil

        var newIndex: Int
        var attempts = 0

        repeat {
            newIndex = Int.random(in: 0..<focusDots.count)
            attempts += 1

            if let prevPos = previousPosition {
                let newPos = focusDots[newIndex].position
                if distance(between: prevPos, and: newPos) >= minimumFocusDistance {
                    break
                }
            } else {
                break
            }

        } while attempts < maxSelectionAttempts

        focusDots[newIndex].view.backgroundColor = .red
        currentRedIndex = newIndex
    }

    private func resetPreviousRedDot() {
        if let index = currentRedIndex {
            focusDots[index].view.backgroundColor = .white
        }
    }

    private func distance(between p1: CGPoint, and p2: CGPoint) -> CGFloat {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func navigate(to storyboard: String,
                  id identifier: String,
                  nextExercise: Exercise?) {

        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)

        // If we are navigating to another exercise
        if let nextExercise,
           let exerciseVC = vc as? ExerciseFlowHandling {
            exerciseVC.exercise = nextExercise
            exerciseVC.inTodaySet = 1
        }

        // If we are navigating to completion
        if let completionVC = vc as? CompletionViewController {
            if (inTodaySet == 0) {
                completionVC.source = .Recommended
            }
        }

        navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: Dot Model
struct FocusDot {
    let position: CGPoint
    let view: UIView
}
