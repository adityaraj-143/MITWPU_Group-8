//
//  SmoothPursuitViewController.swift
//  figure8_pattern
//
//  Created by SDC-USER on 21/01/26.
//

import UIKit

class SmoothPursuitViewController: UIViewController, ExerciseAlignmentMonitoring, ExerciseFlowHandling {
    
    @IBOutlet weak var timer_label: UILabel!
    
    var exercise: Exercise?
    var inTodaySet: Int? = 0
    private let exerciseDuration = 10
    var referenceDistance: Int = 40   // default fallback
    private var coordinateTimer: Timer?
    
    private var monitorTimer: Timer?
    private var hasNavigatedToCompletion = false
    private var didExitManually = false
    
    // MARK: UI Elements
    let exerciseContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let dotView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        view.backgroundColor = .red
        view.layer.cornerRadius = 12.5
        return view
    }()
    
    var displayLink: CADisplayLink?
    var velocity = CGVector(dx: 0, dy: 0)
    var speed: CGFloat = 120
    var lastTimestamp: CFTimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startCountdownThenExercise {
            self.setupExerciseContainer()
            self.startSmoothPursuit()
            
            ExerciseSessionManager.shared.onSessionCompleted = { [weak self] in
                guard let self = self else { return }
                guard !self.hasNavigatedToCompletion else { return }
                guard !self.didExitManually else { return }   // ⭐️ THE FIX

                self.hasNavigatedToCompletion = true

                self.stopAllTimers()
                ExerciseSessionManager.shared.endSession(resetCamera: true)

                self.handleExerciseCompletion()
            }
            
            
            // Start timed session
            guard let exercise = self.exercise else {
                assertionFailure("Exercise not set in SmoothPursuitViewController")
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
        monitorTimer?.invalidate()
        monitorTimer = nil
    }
    
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        didExitManually = true
        stopAllTimers()
        ExerciseSessionManager.shared.endSession(resetCamera: true)
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
    func setupExerciseContainer() {
        let containerHeight: CGFloat = 550
        
        exerciseContainer.frame = CGRect(
            x: 0,
            y: (view.bounds.height - containerHeight) / 2,
            width: view.bounds.width,
            height: containerHeight
        )
        
        view.addSubview(exerciseContainer)
        
        dotView.center = CGPoint(
            x: exerciseContainer.bounds.midX,
            y: exerciseContainer.bounds.midY
        )
        
        exerciseContainer.addSubview(dotView)
    }
    
    // MARK: Logic
    func startSmoothPursuit() {
        setRandomDirectionAndSpeed()
        
        lastTimestamp = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(updateMotion))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc func updateMotion(link: CADisplayLink) {
        let deltaTime = link.timestamp - lastTimestamp
        lastTimestamp = link.timestamp
        
        var newX = dotView.center.x + velocity.dx * CGFloat(deltaTime)
        var newY = dotView.center.y + velocity.dy * CGFloat(deltaTime)
        
        let radius: CGFloat = 12.5
        let minX = radius
        let maxX = exerciseContainer.bounds.width - radius
        let minY = radius
        let maxY = exerciseContainer.bounds.height - radius
        
        if newX <= minX || newX >= maxX {
            velocity.dx *= -1
            setRandomSpeed()
            newX = max(minX, min(newX, maxX))
        }
        
        if newY <= minY || newY >= maxY {
            velocity.dy *= -1
            setRandomSpeed()
            newY = max(minY, min(newY, maxY))
        }
        
        dotView.center = CGPoint(x: newX, y: newY)
    }
    
    func setRandomDirectionAndSpeed() {
        let angle = CGFloat.random(in: 0...(2 * .pi))
        setRandomSpeed()
        
        velocity = CGVector(
            dx: cos(angle) * speed,
            dy: sin(angle) * speed
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2.0...4.0)) {
            self.setRandomDirectionAndSpeed()
        }
    }
    
    func setRandomSpeed() {
        speed = CGFloat.random(in: 80...200)
        
        let angle = atan2(velocity.dy, velocity.dx)
        velocity = CGVector(
            dx: cos(angle) * speed,
            dy: sin(angle) * speed
        )
    }
    
    // MARK: Countdown
    func startCountdownThenExercise(startExercise: @escaping () -> Void) {
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
    
    func navigate(to storyboard: String,
                  id identifier: String,
                  nextExercise: Exercise?) {
        
        stopAllTimers()
        
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
        if let nextExercise,
           let exerciseVC = vc as? ExerciseFlowHandling {
            exerciseVC.exercise = nextExercise
            exerciseVC.inTodaySet = 1
        }
        
        if let completionVC = vc as? CompletionViewController {
            if (inTodaySet == 0) {
                completionVC.source = .Recommended
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
