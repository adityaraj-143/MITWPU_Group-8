//
//  ExerciseSessionManager.swift
//  EyeRis
//
//  Created by SDC-USER on 23/01/26.
//

import Foundation

final class ExerciseSessionManager {

    static let shared = ExerciseSessionManager()
    private init() {}

    private(set) var referenceDistance: Int = 0
    private(set) var exercise: Exercise?

    func start(exercise: Exercise, referenceDistance: Int) {
        self.exercise = exercise
        self.referenceDistance = referenceDistance
    }

    func reset() {
        exercise = nil
        referenceDistance = 0
    }
}
