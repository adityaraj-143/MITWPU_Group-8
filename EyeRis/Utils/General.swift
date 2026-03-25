//
//  general.swift
//  EyeRis
//
//  Created by SDC-USER on 17/12/25.
//

import Foundation

extension Date {
    var startOfWeek: Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: self
            )
        )!
    }
    
    func startOfWeek(calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
}

// MARK: - Date Helper

/// Helper to create a Date like makeDate(year: 2025, month: 5, day: 8)
func makeDate(year: Int, month: Int, day: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    return Calendar.current.date(from: components) ?? Date()
}
