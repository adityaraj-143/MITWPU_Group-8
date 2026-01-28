//
//  CalendarUtils.swift
//  EyeRis
//
//  Pure reusable calendar utilities (no domain logic)
//

import Foundation

// MARK: - Date Helpers

public extension Date {
    /// Returns the date with time stripped (00:00:00)
    func stripped() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}

// MARK: - Calendar View Models

public struct CalendarDay {
    public let date: Date
    public let isInCurrentMonth: Bool
    public let isMarked: Bool   // generic flag
}

public struct CalendarMonth {
    public let monthDate: Date   // any date within the month
    public let days: [CalendarDay]
}

// MARK: - Calendar Builder

public final class CalendarBuilder {

    private let calendar = Calendar.current

    public init() {}

    /// Builds last N months calendar structure
    public func generateLastMonths(
        count: Int,
        markedDates: Set<Date>
    ) -> [CalendarMonth] {
        
        let today = Date()
        var months: [CalendarMonth] = []

        for offset in 0..<count {
            guard let monthDate = calendar.date(byAdding: .month, value: -offset, to: today) else {
                continue
            }
            
            let month = buildMonth(
                monthDate: monthDate,
                markedDates: markedDates
            )
            
            months.append(month)
        }

        return months.reversed() // oldest -> newest
    }

    // MARK: - Private

    private func buildMonth(
        monthDate: Date,
        markedDates: Set<Date>
    ) -> CalendarMonth {
        
        let components = calendar.dateComponents([.year, .month], from: monthDate)
        let firstOfMonth = calendar.date(from: components)!
        
        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
        
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmptyDays = weekday - 1  // Sunday = 1
        
        var days: [CalendarDay] = []
        
        // Empty slots before first day
        for _ in 0..<leadingEmptyDays {
            days.append(
                CalendarDay(
                    date: Date(),
                    isInCurrentMonth: false,
                    isMarked: false
                )
            )
        }
        
        // Actual days
        for day in range {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
            let strippedDate = date.stripped()
            
            days.append(
                CalendarDay(
                    date: date,
                    isInCurrentMonth: true,
                    isMarked: markedDates.contains(strippedDate)
                )
            )
        }
        
        return CalendarMonth(monthDate: firstOfMonth, days: days)
    }
}
