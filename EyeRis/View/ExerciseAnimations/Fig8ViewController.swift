//
//  Fig8ViewController.swift
//  figure8_pattern
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class Fig8ViewController: UIViewController {

    @IBOutlet weak var timer_label: UILabel!

    // MARK: Properties
    private var keyframes: [DotKeyframe] = []
    private var startTime: CFTimeInterval = 0
    private var displayLink: CADisplayLink?
    private var coordinateTimer: Timer?
    private let figureSize: CGFloat = 220
    private let animationDuration: CGFloat = 8.5
    private let keyframeSteps = 300


    private let dotView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        view.backgroundColor = .red
        view.layer.cornerRadius = 12
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDot()
        generateKeyframes()

        startCountdownThenExercise {
            self.startDotAnimation()
        }
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
}

// MARK: Keyframe Model
struct DotKeyframe {
    let time: CGFloat
    let x: CGFloat
    let y: CGFloat
    let visible: Bool
}
