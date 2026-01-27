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
    
    func getStoryboardName () -> String {
        exerciseStyleMap[id]?.storyboardName ?? "ExerciseList"
        
    }
    
    func getStoryboardID () -> String {
        exerciseStyleMap[id]?.storyboardID ?? "ExerciseListViewController"
    }
    
    func getVC() -> UIViewController.Type {
        exerciseStyleMap[id]?.vcType ?? defaultVCType
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
        
        todaysSet = Array(recommended.shuffled().prefix(4)).map {
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


