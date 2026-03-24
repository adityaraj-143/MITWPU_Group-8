import Foundation

enum AcuityTestType {
    case nearVision
    case distantVision
}

struct SnellenStep {
    let image: String
    let value: String
}

struct SnellenChart {
    let sequence: [SnellenStep]
}

struct TestInstruction {
    let description: [String]
    let images: [String]
}

struct AcuityTest {
    let testType: AcuityTestType
    let instruction: TestInstruction
    let snellenChart: SnellenChart
}

struct BlinkRateTest {
    let instructions: TestInstruction
    let passages: String
    let duration: Int
}


// Results

struct AcuityScore {
    var value: String
    
    func calculate() -> String {
        value
    }
}

struct AcuityTestResult {
    
    let id: Int
    let testType: AcuityTestType
    let testDate: Date
    
    let healthyScore: String
    let leftEyeScore: String
    let rightEyeScore: String
    
    let comment: String
    
    init(
        id: Int,
        testType: AcuityTestType,
        testDate: Date,
        healthyScore: String,
        leftEyeScore: String,
        rightEyeScore: String,
        comment: String = "Overall, your vision is fairly good, but a routine eye check-up or corrective lens may help improve clarity, especially for distance vision."
    ) {
        self.id = id
        self.testType = testType
        self.testDate = testDate
        self.healthyScore = healthyScore
        self.leftEyeScore = leftEyeScore
        self.rightEyeScore = rightEyeScore
        self.comment = comment
    }
}

struct BlinkRateTestResult {
    
    let id: Int
    let blinks: Int
    let duration: Int
    let performedOn: Date
    
    var bpm: Int {
        Int(Double(blinks) * (60.0 / Double(duration)))
    }
}

struct AcuityTestsForADate {
    let date: Date
    let distant: AcuityTestResult
    let near: AcuityTestResult
}

struct BlinkWeek {
    let startDate: Date
    let days: [BlinkRateTestResult?]
}

// Managers
final class AcuityTestResultManager {
    
    static let shared = AcuityTestResultManager()
    
    var results: [AcuityTestResult] {
        AcuityTestResultDataStore.shared.fetchAll()
    }
    
    func groupTestsByDate() -> [AcuityTestsForADate] {
        
        let grouped = Dictionary(grouping: results) {
            Calendar.current.startOfDay(for: $0.testDate)
        }
        
        let sortedDates = grouped.keys.sorted()
        
        var dailyTests: [AcuityTestsForADate] = []
        
        for date in sortedDates {
            
            guard let items = grouped[date] else { continue }
            
            guard
                let distant = items.first(where: { $0.testType == .distantVision }),
                let near = items.first(where: { $0.testType == .nearVision })
            else { continue }
            
            dailyTests.append(
                AcuityTestsForADate(
                    date: date,
                    distant: distant,
                    near: near
                )
            )
        }
        
        return dailyTests
    }
}

extension AcuityTestResultManager {
    
    private func latestTest(of type: AcuityTestType) -> AcuityTestResult? {
        results
            .filter { $0.testType == type }
            .max { $0.testDate < $1.testDate }
    }
    
    func getLastTestDVA() -> AcuityTestResult? {
        latestTest(of: .distantVision)
    }
    
    func getLastTestNVA() -> AcuityTestResult? {
        latestTest(of: .nearVision)
    }
    
    func getDueDate() -> String {
        
        let groupedResults = groupTestsByDate()
        
        guard let lastDate = groupedResults.last?.date else {
            return "Due: Today"
        }
        
        let calendar = Calendar.current
        
        guard let dueDate = calendar.date(
            byAdding: .day,
            value: 20,
            to: lastDate
        ) else {
            return "Due: Today"
        }
        
        if calendar.isDateInToday(dueDate) || dueDate < Date() {
            return "Due: Today"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return "Due: \(formatter.string(from: dueDate))"
    }
    
    func getLastTestComment() -> String? {
        guard
            let nva = getLastTestNVA(),
            let dva = getLastTestDVA()
        else { return nil }
        
        return nva.comment.isEmpty ? dva.comment : nva.comment
    }
}

final class BlinkRateTestResultManager {

    static let shared = BlinkRateTestResultManager()

    var results: [BlinkRateTestResult] {
        BlinkRateTestResultDataStore.shared.fetchAll()
    }
    
    func getTodayResult() -> BlinkRateTestResult? {
        results
            .filter { Calendar.current.isDateInToday($0.performedOn) }
            .max { $0.performedOn < $1.performedOn }
    }
    
    func getLastTestResult() -> BlinkRateTestResult? {
        results.max { $0.performedOn < $1.performedOn }
    }

    func makeLast4Weeks() -> [BlinkWeek] {

        var calendar = Calendar.current
        calendar.firstWeekday = 2

        let today = calendar.startOfDay(for: Date())

        let byDate = Dictionary(grouping: results) {
            calendar.startOfDay(for: $0.performedOn)
        }.mapValues {
            $0.max { $0.performedOn < $1.performedOn }!
        }

        var weeks: [BlinkWeek] = []

        for offset in (0..<4).reversed() {

            guard let weekStart = calendar.date(
                byAdding: .weekOfYear,
                value: -offset,
                to: today
            )?.startOfWeek(calendar: calendar)
            else { continue }

            let days = (0..<7).map { day -> BlinkRateTestResult? in
                let date = calendar.date(
                    byAdding: .day,
                    value: day,
                    to: weekStart
                )!
                return byDate[date]
            }

            weeks.append(
                BlinkWeek(startDate: weekStart, days: days)
            )
        }

        return weeks
    }
}


// DataStores

final class AcuityTestResultDataStore {

    static let shared = AcuityTestResultDataStore()

    func save(_ result: AcuityTestResult) {
        AcuityTestResultStore().save(result)
    }

    func fetchAll() -> [AcuityTestResult] {
        AcuityTestResultStore().fetchAll()
    }
}

final class BlinkRateTestResultDataStore {

    static let shared = BlinkRateTestResultDataStore()

    func save(_ result: BlinkRateTestResult) {
        BlinkRateTestResultStore().save(result)
    }

    func fetchAll() -> [BlinkRateTestResult] {
        BlinkRateTestResultStore().fetchAll()
    }
}


// Test definitions

final class AcuityTestStore {

    static let shared = AcuityTestStore()

    private init() {}

    var nearVisionTest: AcuityTest = mockTestNVA
    var distantVisionTest: AcuityTest = mockTestDVA
}

final class BlinkRateTestStore {
    
    static let shared = BlinkRateTestStore()
    
    private init() {}
    
    var test: BlinkRateTest = mockTestBlink
}
