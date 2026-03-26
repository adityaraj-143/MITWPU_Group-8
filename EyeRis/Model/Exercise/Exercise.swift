
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
    
    func getPerformanceInstruction () -> [ExerciseStage]{
        ExerciseInfo[id]?.exerciseData ?? []
    }
    
    func getImpact () -> String {
        ExerciseInfo[id]?.impact ?? "Impacts unknown"
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
        
        let filtered = exercises.filter { exercise in
            !Set(exercise.targetedConditions).intersection(userConditions).isEmpty
        }
        
        // Default to Palming (1), Blinking (3), Figure 8 (5) if no matches
        if filtered.isEmpty {
            recommended = exercises.filter { [1, 3, 5].contains($0.id) }
        } else {
            recommended = filtered
        }
        
        // Exercises matching user's conditions (high priority)
        let matching = exercises.filter { exercise in
            !Set(exercise.targetedConditions).intersection(userConditions).isEmpty
        }
        
        // Exercises not matching conditions (fallback)
        let nonMatching = exercises.filter { exercise in
            Set(exercise.targetedConditions).intersection(userConditions).isEmpty
        }
        
        // Shuffle to avoid same order every day
        let prioritized = matching.shuffled()
        let fallback = nonMatching.shuffled()
        
        // Pick up to 4 exercises prioritizing matches
        let selected = Array((prioritized + fallback).prefix(4))
        
        todaysSet = selected.map {
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

// One Item of the today's exercise set
struct TodaysExercise {
    let exercise: Exercise
    var isCompleted: Bool
}


