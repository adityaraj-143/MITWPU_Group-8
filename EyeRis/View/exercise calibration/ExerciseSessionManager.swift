//
//  ExerciseSessionManager.swift
//  EyeRis
//
//  Created by SDC-USER on 23/01/26.
//

import Foundation

//
//  ExerciseSessionManager.swift
//  EyeRis
//

import Foundation

final class ExerciseSessionManager {

    static let shared = ExerciseSessionManager()
    private init() {}

    private(set) var referenceDistance: Int = 0
    private(set) var exercise: Exercise?

    // Session timing
    private var sessionTimer: Timer?
    private(set) var duration: Int = 0      // total exercise duration in seconds
    private var elapsedTime: Int = 0

    var onSessionCompleted: (() -> Void)?

    func start(exercise: Exercise,
               referenceDistance: Int,
               time duration: Int) {

        self.exercise = exercise
        self.referenceDistance = referenceDistance
        self.duration = duration
        self.elapsedTime = 0

        startSessionTimer()
    }

    func endSession(resetCamera: Bool = true) {
        stopSessionTimer()
        exercise = nil
        referenceDistance = 0
        duration = 0
        elapsedTime = 0

        if resetCamera {
            CameraManager.shared.reset()
        }

        onSessionCompleted?()
    }

    private func startSessionTimer() {
        stopSessionTimer()

        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { return }

            self.elapsedTime += 1

            if self.elapsedTime >= self.duration {
                timer.invalidate()
                self.endSession(resetCamera: false) // chaining exercises keeps camera alive
            }
        }
    }

    private func stopSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = nil
    }
}
