//
//  Exercise.swift
//  EyeRis
//
//  Created by SDC-USER on 12/12/25.
//

import Foundation
import UIKit

// MARK: - Exercise

struct Exercise {
    let id: Int
    let name: String
    let duration: Int
    let instructions: ExerciseInstruction
    let targetedConditions: [Conditions]
}

extension Exercise {
    
    func getIcon() -> String {
        exerciseStyleMap[id]?.icon ?? "questionmark.circle"
    }
    
    func getBGColor() -> UIColor {
        exerciseStyleMap[id]?.bgColor ?? UIColor.systemGray.withAlphaComponent(0.1)
    }
    
    func getIconBGColor() -> UIColor {
        exerciseStyleMap[id]?.iconBGColor ?? .systemGray
    }
}

// MARK: - Exercise List

struct ExerciseList {
    let exercises: [Exercise]
    let recommended: [Exercise]
    let todaysSet: [TodaysExercise]
    
    static private(set) var shared: ExerciseList?
    
    static func makeOnce(user: User) {
        // Only create once, so shuffle happens once
        if shared == nil {
            shared = ExerciseList(user: user)
        }
    }
    
    static func reset() {
        shared = nil
    }
    
    init(user: User) {
        self.exercises = allExercises
        // Convert both arrays to Sets for fast intersection
        let userConditions = Set(user.eyeHealthData.condition)
        // Recommend exercises that target at least one of the user's conditions
        recommended = exercises.filter { exercise in
            !Set(exercise.targetedConditions).intersection(userConditions).isEmpty
        }
        todaysSet = Array(recommended.shuffled().prefix(4)).map {
            TodaysExercise(exercise: $0, isCompleted: false)
        }
    }
}


// MARK: - Exercise Instruction

struct ExerciseInstruction {
    let title: String
    let description: String
    let video: String
}

// MARK: - Performed Exercise Stat

struct PerformedExerciseStat {
    let id: Int
    let name: String
    let performedOn: Date
    let accuracy: Int
    let speed: Int
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

// MARK: - Exercise History / Stats Store

struct ExerciseHistory {
    
    private let performedExercises: [PerformedExerciseStat]
    private let calendar = Calendar.current
    
    // MARK: - Init
    init(stats: [PerformedExerciseStat] = mockPerformedExerciseStats) {
        self.performedExercises = stats
    }
    
    // MARK: - Date Ranges
    
    /// Last 4 weeks (28 days) ending at the most recent performed exercise
    func fourWeekDateRange() -> [Date] {
        guard let latestDate = performedExercises.map(\.performedOn).max() else {
            return []
        }
        
        return (0..<28)
            .compactMap { calendar.date(byAdding: .day, value: -$0, to: latestDate) }
            .map { calendar.startOfDay(for: $0) }
            .reversed()
    }
    
    // MARK: - Performed Dates
    
    func performedExerciseDates() -> Set<Date> {
        Set(performedExercises.map {
            calendar.startOfDay(for: $0.performedOn)
        })
    }
    
    // MARK: - Grouping
    
    func groupedByDate() -> [Date: [PerformedExerciseStat]] {
        Dictionary(grouping: performedExercises) {
            calendar.startOfDay(for: $0.performedOn)
        }
    }
    
    // MARK: - Queries
    
    func exercises(on date: Date) -> [PerformedExerciseStat] {
        groupedByDate()[calendar.startOfDay(for: date)] ?? []
    }
    
    func lastExercise() -> PerformedExerciseStat? {
        performedExercises.max { $0.performedOn < $1.performedOn }
    }
    
    func lastExerciseSummary() -> ExerciseSummary? {
        let grouped = groupedByDate()
        
        guard let latestDate = grouped.keys.max(),
              let dayExercises = grouped[latestDate],
              !dayExercises.isEmpty else {
            return nil
        }
        
        let avgAccuracy =
        dayExercises.map(\.accuracy).reduce(0, +) / dayExercises.count
        
        let avgSpeed =
        dayExercises.map(\.speed).reduce(0, +) / dayExercises.count
        
        return ExerciseSummary(
            accuracy: avgAccuracy,
            speed: avgSpeed
        )
    }
}

extension Exercise {

    var storyboardName: String {
        switch id {
        case 8:
            return "focusShifting"
        case 3:
            return "Figure8"
        case 13:
            return "SmoothPursuit"
        default:
            return "Figure8"
        }
    }

    var viewControllerIdentifier: String {
        switch id {
        case 8:
            return "FocusShiftingViewController"
        case 3:
            return "Fig8ViewController"
        case 13:
            return "smoothPursuitViewController"
        default:
            return "Fig8ViewController"
        }
    }
}
