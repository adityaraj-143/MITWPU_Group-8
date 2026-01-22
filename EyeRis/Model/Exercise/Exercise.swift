//
//  Exercise.swift
//  EyeRis
//
//  Created by SDC-USER on 12/12/25.
//

import Foundation
import UIKit

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


struct ExerciseSummary {
    let accuracy: Int
    let speed: Int
}

struct PerformedExerciseStatResponse {
    
    private let stats: [PerformedExerciseStat]
    private let calendar = Calendar.current
    
    // MARK: - Init
    
    init(stats: [PerformedExerciseStat] = mockPerformedExerciseStats) {
        self.stats = stats
    }
    
    // MARK: - Four Week Dates (28 days)
    
    func getFourWeekDateRange() -> [Date] {
        guard let latestDate = stats.map({ $0.performedOn }).max() else {
            return []
        }
        
        var dates: [Date] = []
        
        for dayOffset in 0..<28 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: latestDate) {
                dates.append(calendar.startOfDay(for: date))
            }
        }
        
        return dates.reversed()
    }
    
    // MARK: - Performed Dates
    
    func getPerformedExerciseDates() -> Set<Date> {
        let dates = stats.map {
            calendar.startOfDay(for: $0.performedOn)
        }
        return Set(dates)
    }
    
    // MARK: - Grouped Exercises
    
    func groupExercisesByDate() -> [Date: [PerformedExerciseStat]] {
        Dictionary(grouping: stats) {
            calendar.startOfDay(for: $0.performedOn)
        }
    }
    
    // MARK: - Exercises for Day
    
    func exercises(for date: Date) -> [PerformedExerciseStat] {
        let grouped = groupExercisesByDate()
        return grouped[calendar.startOfDay(for: date)] ?? []
    }
    
    func getLastExercise() -> PerformedExerciseStat {
        stats.max { $0.performedOn < $1.performedOn }!
    }
    
    func getLastExercise() -> ExerciseSummary {
        
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: stats) {
            calendar.startOfDay(for: $0.performedOn)
        }
        
        guard let latestDate = grouped.keys.max(),
              let dayExercises = grouped[latestDate]
        else {
            return ExerciseSummary(accuracy: 0, speed: 0)
        }
        
        let avgAccuracy =
        dayExercises.map { $0.accuracy }.reduce(0, +) / dayExercises.count
        
        let avgSpeed =
        dayExercises.map { $0.speed }.reduce(0, +) / dayExercises.count
        
        return ExerciseSummary(
            accuracy: avgAccuracy,
            speed: avgSpeed
        )
    }
}


// MARK: - Mock Data

struct RecommendedExerciseMock {
    let title: String
    let subtitle: String
    let icon: UIImage
    let bgColor: UIColor
    let iconBG: UIColor
}

struct TestMock {
    let title: String
    let subtitle: String
    let iconName: String
    let iconBGColor: UIColor
}

var recommendedExercises: [RecommendedExerciseMock] = [
    
    
    .init(
        title: "Focus Shift",
        subtitle: "20224 people did this today",
        icon: UIImage(named: "all_inclusive_32dp_E3E3E3_FILL0_wght400_GRAD0_opsz40")!,
        bgColor: UIColor(hex: "D9ECFF"),          // from Light Adaption
        iconBG: UIColor(hex: "6FAEFF")
    ),
    
        .init(
            title: "Near Vision",
            subtitle: "204 people did this today",
            icon: UIImage(named: "all_inclusive_32dp_E3E3E3_FILL0_wght400_GRAD0_opsz40")!,
            bgColor: UIColor(hex: "E9E0F8"),          // from Guided Blinking
            iconBG: UIColor(hex: "A68BEB")
        ),
    
        .init(
            title: "Eye Stretch",
            subtitle: "204 people did this today",
            icon: UIImage(named: "all_inclusive_32dp_E3E3E3_FILL0_wght400_GRAD0_opsz40")!,
            bgColor: UIColor(hex: "FFECC2"),          // from Smooth Pursuit
            iconBG: UIColor(hex: "F5B942")
        ),
    .init(
        title: "Blink Boost",
        subtitle: "204 people did this today",
        icon: UIImage(named: "all_inclusive_32dp_E3E3E3_FILL0_wght400_GRAD0_opsz40")!,
        bgColor: UIColor(hex: "D3F2E8"),          // from Figure 8
        iconBG: UIColor(hex: "5BC8A8")
    ),
    
        .init(
            title: "Relax Mode",
            subtitle: "204 people did this today",
            icon: UIImage(named: "all_inclusive_32dp_E3E3E3_FILL0_wght400_GRAD0_opsz40")!,
            bgColor: UIColor(hex: "F8D7DC"),          // from Focus Shifting
            iconBG: UIColor(hex: "E66A7A")
        )
]


var tests: [TestMock] = [
    .init(title: "Acuity Test", subtitle: "Check sharpness", iconName: "all_inclusive_32dp_E3E3E3_FILL0_wght400_GRAD0_opsz40", iconBGColor: .systemPink),
    .init(title: "Blink Rate", subtitle: "Check blinking", iconName: "all_inclusive_32dp_E3E3E3_FILL0_wght400_GRAD0_opsz40", iconBGColor: .systemIndigo)
]
// One Item of the today's exercise set
struct TodaysExerciseItem {
    let id: Int
    let name: String
    let icon: String
    let instruction: String
    let duration: String = "1 min"
    let isCompleted: Bool = true
}



