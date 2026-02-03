//
//  Test.swift
//  EyeRis
//
//  Created by SDC-USER on 12/12/25.
//

import Foundation

struct AcuityScore{ // need to change this (research needed)
    var temp: String
    func calcScore () {
        // should return the score of the test
    }
}

enum AcuityTestType{
    case NearVision
    case DistantVision
}

struct SnellenStep {
    let image: String
    let value: String
}

struct SnellenChart {
    let sequence: [SnellenStep]
}

struct TestInstruction{
//  var title: String
    var description: [String]
    var images: [String]
}

struct AcuityTest {
    var testType: AcuityTestType
    var instruction: TestInstruction
    var snellenChart: SnellenChart
}

struct AcuityTestResult{
    var id: Int
    var testType: AcuityTestType
    var testDate: Date
    var heathyScore: String
    var leftEyeScore: String // the format of scores would later change, kept it string for dummy data
    var rightEyeScore: String
    var comment: String = "Overall, your vision is fairly good, but a routine eye check-up or corrective lens may help improve clarity, especially for distance vision."
}

func calcAcuityScore(level: Int) -> String {
    let snellenMap = [
        "20/200",
        "20/100",
        "20/80",
        "20/60",
        "20/40",
        "20/30",
        "20/25",
        "20/20",
        "20/15"
    ]
    
    guard level >= 0 && level < snellenMap.count else {
        return "N/A"
    }
    
    return snellenMap[level]
}

struct AcuityTestsForADate {
    let date: Date
    let distant: AcuityTestResult
    let near: AcuityTestResult
}

final class AcuityTestResultResponse {
    static let shared = AcuityTestResultResponse()
    var results : [AcuityTestResult]
    
    init() {
        results = dummyAcuityResults
    }
    
    func groupTestsByDate() -> [AcuityTestsForADate] {
        // 1. Group every test result by its testDate
        let grouped = Dictionary(grouping: results) {
            Calendar.current.startOfDay(for: $0.testDate)
        }

        // 2. Sort dates in ascending order
        let sortedDates = grouped.keys.sorted()
        
        var dailyTests: [AcuityTestsForADate] = []
        
        // 3. Build a DailyAcuityTests object for each date
        for date in sortedDates {
            guard let items = grouped[date] else { continue }
            
            // Must have BOTH tests for that date
            guard
                let distant = items.first(where: { $0.testType == .DistantVision }),
                let near    = items.first(where: { $0.testType == .NearVision })
            else {
                continue
            }
            
            dailyTests.append(
                AcuityTestsForADate(date: date, distant: distant, near: near)
            )
        }
        return dailyTests
    }
}

extension AcuityTestResultResponse {

    private func latestTest(of type: AcuityTestType) -> AcuityTestResult? {
        results
            .filter { $0.testType == type }
            .max { $0.testDate < $1.testDate }
    }
    
    func getDueDate() -> String {
        let groupedResults = groupTestsByDate()
        
        guard let lastDate = groupedResults.last?.date else {
            return "Due: Today"
        }
        
        let calendar = Calendar.current
        
        // Add 20 days to the last test date
        guard let dueDate = calendar.date(byAdding: .day, value: 20, to: lastDate) else {
            return "Due: Today"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        // If due date is today or past, show "Due: Today"
        if calendar.isDateInToday(dueDate) || dueDate < Date() {
            return "Due: Today"
        }
        
        return "Due: \(formatter.string(from: dueDate))"
    }


    func getLastTestDVA() -> AcuityTestResult? {
        latestTest(of: .DistantVision)
    }

    func getLastTestNVA() -> AcuityTestResult? {
        latestTest(of: .NearVision)
    }
    
    func getLastComment() -> String {
        guard
            let lastNVA = getLastTestNVA(),
            let lastDVA = getLastTestDVA()
        else {
            return "No recent vision test data available."
        }

        return getComment(NVAScore: lastNVA, DVAScore: lastDVA)
    }
}

func getComment(
    NVAScore: AcuityTestResult,
    DVAScore: AcuityTestResult
) -> String {

    guard
        let nva = snellenValue(NVAScore.leftEyeScore),
        let dva = snellenValue(DVAScore.leftEyeScore)
    else {
        return "We couldn’t evaluate your vision scores properly. Please retake the test."
    }

    let worstScore = max(nva, dva)

    switch worstScore {
    case 15...20:
        return "Great news! Your near and distance vision are both in excellent range. Keep maintaining healthy eye habits and regular screen breaks."

    case 25...40:
        return "Your vision is generally fine, though there are mild signs of strain or reduced clarity. Monitoring your eye health and taking periodic tests is recommended."

    default:
        return "Your vision scores indicate noticeable difficulty in clarity. It is strongly recommended that you consult an eye care professional for a comprehensive examination."
    }
}

// To convedr the Snellen Value to a Numeric Value so that it is easy to compare
private func snellenValue(_ score: String) -> Int? {
    let parts = score.split(separator: "/")
    guard parts.count == 2, let value = Int(parts[1]) else {
        return nil
    }
    return value
}


struct BlinkRateTest{
    var instructions: TestInstruction
    var passages: String
    var duration: Int = 30
}

struct BlinkRateTestResult {
    var id: Int
    var blinks: Int
    var duration: Int         
    var performedOn: Date

    var bpm: Int {
        Int(Double(blinks) * (60.0 / Double(duration)))
    }
}

struct BlinkWeek {
    let startDate: Date
    let days: [BlinkRateTestResult?] // count = 7
}

struct BlinkRateTestResultResponse {
    private let results: [BlinkRateTestResult]
}



