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

    private var sessionTimer: Timer?
    private var elapsedTime: Int = 0

    // Callback that VC sets
    var onSessionCompleted: (() -> Void)?

    func start(exercise: Exercise, referenceDistance: Int, time: Int) {
        self.exercise = exercise
        self.referenceDistance = referenceDistance
        self.elapsedTime = 0

        startSessionTimer(duration: time)
    }

    func endSession() {
        stopSessionTimer()
        exercise = nil
        referenceDistance = 0
        elapsedTime = 0

        CameraManager.shared.reset()

        // Notify VC
        onSessionCompleted?()
    }

    private func startSessionTimer(duration: Int) {
        stopSessionTimer()

        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            self.elapsedTime += 1

            if self.elapsedTime >= duration {
                timer.invalidate()
                self.endSession()
            }
        }
    }

    private func stopSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = nil
    }
}
