import Foundation
import UIKit

// MARK: - Performed Exercise Stat

struct PerformedExerciseStat {
    let id: Int
    let name: String
    let performedOn: Date
    let accuracy: Int
    let speed: Int
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

