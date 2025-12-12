//
//  Exercise.swift
//  EyeRis
//
//  Created by SDC-USER on 12/12/25.
//

import Foundation

struct Exercise{
    var id: Int
    var name: String
    var duration: Int
    var instructions: ExerciseInstruction
    var targetedConditions : [Conditions]
    // to see if the exercise is recommended on the basis of userEyeConditions
    func isRecommended(for user: User) -> Bool {
        // Convert both arrays to Sets for fast intersection
        let userConditions = Set(user.eyeHealthData.condition)
        let exerciseConditions = Set(targetedConditions)

        // If intersection is not empty → recommended
        return !userConditions.intersection(exerciseConditions).isEmpty
    }
}

struct ExerciseInstruction{
    var title: String
    var description: [String]
    var video: String
}

struct PerformedExerciseStat {
    var id: Int
    var name: String
    var performedOn: Date
    var accuracy: Int
    var speed: Int
}

struct ExerciseHistory{
//    func avgSpeed() -> Int {}
//    func avgAccuracy() -> Int{}
    var date: Date // these would be replaced by functions when the data is dynamic
    var avgSpeed: Int
    var avgAccuracy: Int
    var comment: String = "Your eye coordination looks good. Regular exercise and care will maintain your eye health."
    var exercisesDetails: [PerformedExerciseStat]
}
