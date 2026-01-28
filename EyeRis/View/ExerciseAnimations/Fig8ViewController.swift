//
//  Fig8ViewController.swift
//  figure8_pattern
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class Fig8ViewController: UIViewController, ExerciseAlignmentMonitoring, ExerciseFlowHandling {
    
    @IBOutlet weak var timer_label: UILabel!
    
    var exercise: Exercise?
    var inTodaySet: Int? = 0
    
    var referenceDistance: Int = 40   // default fallback

    
    // MARK: Properties
    private var keyframes: [DotKeyframe] = []
    private var startTime: CFTimeInterval = 0
    private var displayLink: CADisplayLink?
    private var coordinateTimer: Timer?
    private let figureSize: CGFloat = 220
    private let animationDuration: CGFloat = 8.5
    private let keyframeSteps = 300
    
    private var monitorTimer: Timer?
    
    var exerciseDuration = 5
    
    private let dotView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        view.backgroundColor = .red
        view.layer.cornerRadius = 12
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        //        exerciseDuration = exercise.duration
        
        setupDot()
        generateKeyframes()
        
        startCountdownThenExercise {
            self.startDotAnimation()
            
            ExerciseSessionManager.shared.onSessionCompleted = { [weak self] in
                self?.handleExerciseCompletion()
            }
            
            guard let exercise = self.exercise else {
                assertionFailure("Exercise not set in Fig8ViewController")
                return
            }

            ExerciseSessionManager.shared.start(
                exercise: exercise,
                referenceDistance: 40,
                time: self.exerciseDuration
            )

        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAlignmentMonitoring(timer: &monitorTimer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // If pause modal is being shown, just stop monitoring
        if navigationController?.topViewController is PauseModalViewController {
            monitorTimer?.invalidate()
            monitorTimer = nil
            return
        }

        // If user presses BACK → exit exercise flow completely
        if isMovingFromParent {
            monitorTimer?.invalidate()
            monitorTimer = nil
            ExerciseSessionManager.shared.endSession(resetCamera: true)
        }
    }

    
    @IBAction func pauseTapped(_ sender: UIBarButtonItem) {
        showPause(reason: .manual)
    }
    
    // MARK: Setup
    private func setupDot() {
        view.addSubview(dotView)
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
    
    // MARK: Keyframe Generation
    private func generateKeyframes() {
        keyframes.removeAll()
        
        let centerX = view.bounds.midX
        let centerY = view.bounds.midY
        
        for step in 0...keyframeSteps {
            let t = CGFloat(step) / CGFloat(keyframeSteps) * 2 * .pi
            let time = CGFloat(step) / CGFloat(keyframeSteps) * animationDuration
            
            let x = centerX + figureSize * sin(t) * cos(t)
            let y = centerY + figureSize * sin(t)
            
            keyframes.append(
                DotKeyframe(time: time, x: x, y: y, visible: true)
            )
        }
    }
    // MARK: Logic
    private func startDotAnimation() {
        startTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateDotPosition))
        displayLink?.add(to: .main, forMode: .default)
        
        startCoordinateTracking()
    }
    
    @objc private func updateDotPosition() {
        guard keyframes.count >= 2 else { return }
        
        let elapsedTime = CGFloat(CACurrentMediaTime() - startTime)
        
        for index in 0..<keyframes.count - 1 {
            let currentFrame = keyframes[index]
            let nextFrame = keyframes[index + 1]
            
            if elapsedTime >= currentFrame.time && elapsedTime <= nextFrame.time {
                let progress = (elapsedTime - currentFrame.time) / (nextFrame.time - currentFrame.time)
                
                let x = currentFrame.x + (nextFrame.x - currentFrame.x) * progress
                let y = currentFrame.y + (nextFrame.y - currentFrame.y) * progress
                
                dotView.center = CGPoint(x: x, y: y)
                dotView.alpha = currentFrame.visible ? 1.0 : 0.0
                return
            }
        }
        
        // Loop animation
        if elapsedTime > animationDuration {
            startTime = CACurrentMediaTime()
        }
    }
    
    private func startCoordinateTracking() {
        coordinateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let position = self.currentDotPosition()
            print("Current Dot Position:", position)
        }
    }
    
    private func currentDotPosition() -> CGPoint {
        let elapsed = CGFloat(CACurrentMediaTime() - startTime)
        return position(at: elapsed)
    }
    
    private func position(at time: CGFloat) -> CGPoint {
        let normalizedTime = (time.truncatingRemainder(dividingBy: animationDuration)) / animationDuration
        let t = normalizedTime * 2 * .pi
        
        let centerX = view.bounds.midX
        let centerY = view.bounds.midY
        
        let x = centerX + figureSize * sin(t) * cos(t)
        let y = centerY + figureSize * sin(t)
        
        return CGPoint(x: x, y: y)
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
    
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        monitorTimer?.invalidate()
        monitorTimer = nil
        
        // End exercise session (stops camera + resets state)
        ExerciseSessionManager.shared.endSession(resetCamera: true)
        
        // Pop directly to ExerciseList
        popToExerciseList()
    }

    func navigate(to storyboardName: String,
                  id identifier: String,
                  nextExercise: Exercise?) {

        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)

        // If this is another exercise screen
        if let nextExercise,
           let exerciseVC = vc as? ExerciseFlowHandling {
            exerciseVC.exercise = nextExercise
            exerciseVC.inTodaySet = 1
        }

        // If this is the completion screen
        if let completionVC = vc as? CompletionViewController {
            completionVC.source = .Exercise
        }

        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: Keyframe Model
struct DotKeyframe {
    let time: CGFloat
    let x: CGFloat
    let y: CGFloat
    let visible: Bool
}

