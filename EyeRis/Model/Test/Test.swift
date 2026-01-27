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
//  put the details for the snellen chart, and respective score details in the score struct
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
        let grouped = Dictionary(grouping: results, by: { $0.testDate })
        
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

    func getLastTestDVA() -> AcuityTestResult? {
        latestTest(of: .DistantVision)
    }

    func getLastTestNVA() -> AcuityTestResult? {
        latestTest(of: .NearVision)
    }
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

