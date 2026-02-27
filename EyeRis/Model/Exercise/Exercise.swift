//
//  Exercise.swift
//  EyeRis
//
//  Created by SDC-USER on 12/12/25.
//

import Foundation
import UIKit

// MARK: - Exercise

enum ExerciseType {
    case onScreen
    case offScreen
}

struct Exercise: Equatable {
    let id: Int
    let name: String
    let duration: Int
    let instructions: ExerciseInstruction
    let targetedConditions: [Conditions]
    let type: ExerciseType
    
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ExerciseStage {
    let instruction: String
    let duration: Int
}

extension Exercise {
    
    func getIcon() -> String {
        ExerciseInfo[id]?.icon ?? "questionmark.circle"
    }
    
    func getBGColor() -> UIColor {
        ExerciseInfo[id]?.bgColor ?? UIColor.systemGray.withAlphaComponent(0.1)
    }
    
    func getIconBGColor() -> UIColor {
        ExerciseInfo[id]?.iconBGColor ?? .systemGray
    }
    
    func getStoryboardName () -> String {
        ExerciseInfo[id]?.storyboardName ?? "ExerciseList"
        
    }
    
    func getStoryboardID () -> String {
        ExerciseInfo[id]?.storyboardID ?? "ExerciseListViewController"
    }
    
//    func getVC() -> UIViewController.Type {
//        ExerciseInfo[id]?.vcType ?? defaultVCType
//    }
    
    func get () -> [ExerciseStage]{
        ExerciseInfo[id]?.exerciseData ?? []
    }
}

// MARK: - Exercise List

final class ExerciseList {
    let exercises: [Exercise]
    let recommended: [Exercise]
    private(set) var todaysSet: [TodaysExercise]
    
    static private(set) var shared: ExerciseList?
    
    static func makeOnce(user: User) {
        if shared == nil {
            shared = ExerciseList(user: user)
        }
    }
    
    static func reset() {
        shared = nil
    }
    
    init(user: User) {
        self.exercises = allExercises
        
        let userConditions = Set(user.eyeHealthData.condition)
        
        recommended = exercises.filter { exercise in
            !Set(exercise.targetedConditions).intersection(userConditions).isEmpty
        }
        
        // IDs that must always be present
        let mandatoryIDs: Set<Int> = [3, 8, 13]
        
        // Get mandatory exercises
        let mandatoryExercises = exercises.filter { mandatoryIDs.contains($0.id) }
        
        // Get remaining recommended exercises excluding mandatory ones
        let remaining = recommended.filter { !mandatoryIDs.contains($0.id) }
        
        // Fill the rest of the set (total = 4)
        let neededCount = max(0, 4 - mandatoryExercises.count)
        let randomExtras = Array(remaining.shuffled().prefix(neededCount))
        
        let finalSet = mandatoryExercises + randomExtras
        
        todaysSet = finalSet.map {
            TodaysExercise(exercise: $0, isCompleted: false)
        }
    }
    
    
    // MARK: - Mutating logic lives here
    
    func markCompleted(exercise: Exercise) {
        guard let index = todaysSet.firstIndex(where: {
            $0.exercise.id == exercise.id
        }) else { return }
        
        todaysSet[index].isCompleted = true
    }
    
    func nextExercise(after exercise: Exercise) -> Exercise? {
        guard let index = todaysSet.firstIndex(where: {
            $0.exercise.id == exercise.id
        }) else { return nil }
        
        let nextIndex = index + 1
        guard nextIndex < todaysSet.count else { return nil }
        
        return todaysSet[nextIndex].exercise
    }
}

// MARK: - Exercise Instruction

struct ExerciseInstruction {
    let title: String
    let description: String
    let video: String
}

// MARK: - Exercise Summary

struct ExerciseSummary {
    let accuracy: Int
    let speed: Int
}

// One Item of the today's exercise set
struct TodaysExercise {
    let exercise: Exercise
    var isCompleted: Bool
}


