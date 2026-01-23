//
//  TestMockDataStore.swift
//  EyeRis
//
//  Created by SDC-USER on 12/12/25.
//

import Foundation

//MARK: TEST RESULTS
// Dummy data for Test Results
let dummyAcuityResults: [AcuityTestResult] = [
    // 1) May 8, 2025
    AcuityTestResult(
        id: 1,
        testType: .DistantVision,
        testDate: makeDate(year: 2025, month: 5, day: 8),
        heathyScore: "20/25",
        leftEyeScore: "15/25",
        rightEyeScore: "15/25"
    ),
    AcuityTestResult(
        id: 2,
        testType: .NearVision,
        testDate: makeDate(year: 2025, month: 5, day: 8),
        heathyScore: "20/25",
        leftEyeScore: "20/25",
        rightEyeScore: "20/25"
    ),
    
    // 2) April 25, 2025
    AcuityTestResult(
        id: 3,
        testType: .DistantVision,
        testDate: makeDate(year: 2025, month: 4, day: 25),
        heathyScore: "20/25",
        leftEyeScore: "18/25",
        rightEyeScore: "18/25"
    ),
    AcuityTestResult(
        id: 4,
        testType: .NearVision,
        testDate: makeDate(year: 2025, month: 4, day: 25),
        heathyScore: "20/25",
        leftEyeScore: "20/25",
        rightEyeScore: "20/25"
    ),
    
    // 3) April 2, 2025
    AcuityTestResult(
        id: 5,
        testType: .DistantVision,
        testDate: makeDate(year: 2025, month: 4, day: 2),
        heathyScore: "20/25",
        leftEyeScore: "20/30",
        rightEyeScore: "20/25"
    ),
    AcuityTestResult(
        id: 6,
        testType: .NearVision,
        testDate: makeDate(year: 2025, month: 4, day: 2),
        heathyScore: "20/25",
        leftEyeScore: "20/25",
        rightEyeScore: "20/25"
    ),
    
    // 4) March 18, 2025
    AcuityTestResult(
        id: 7,
        testType: .DistantVision,
        testDate: makeDate(year: 2025, month: 3, day: 18),
        heathyScore: "20/25",
        leftEyeScore: "20/40",
        rightEyeScore: "20/30"
    ),
    AcuityTestResult(
        id: 8,
        testType: .NearVision,
        testDate: makeDate(year: 2025, month: 3, day: 18),
        heathyScore: "20/25",
        leftEyeScore: "20/30",
        rightEyeScore: "20/25"
    ),
    
    // 5) March 1, 2025
    AcuityTestResult(
        id: 9,
        testType: .DistantVision,
        testDate: makeDate(year: 2025, month: 3, day: 1),
        heathyScore: "20/25",
        leftEyeScore: "20/25",
        rightEyeScore: "20/30"
    ),
    AcuityTestResult(
        id: 10,
        testType: .NearVision,
        testDate: makeDate(year: 2025, month: 3, day: 1),
        heathyScore: "20/25",
        leftEyeScore: "20/25",
        rightEyeScore: "20/25"
    ),
    
    // 6) February 10, 2025
    AcuityTestResult(
        id: 11,
        testType: .DistantVision,
        testDate: makeDate(year: 2025, month: 2, day: 10),
        heathyScore: "20/25",
        leftEyeScore: "20/30",
        rightEyeScore: "20/30"
    ),
    AcuityTestResult(
        id: 12,
        testType: .NearVision,
        testDate: makeDate(year: 2025, month: 2, day: 10),
        heathyScore: "20/25",
        leftEyeScore: "20/25",
        rightEyeScore: "20/25"
    )
]


let mockTestNVA = AcuityTest(
    testType: .NearVision,
    instruction: TestInstruction(
        description: [
            "Hold your phone about 40 cm away from your eyes (roughly an arm’s length).",
            "Read the letters out loud, then say “Next” to move forward.",
            "If your phone position changes, tap recalibrate to adjust.",
            "Make sure the screen is at eye level and well-lit for best accuracy."
        ],
        images: [
            "testInstruction1",
            "testInstruction2",
            "testInstruction3",
            "testInstruction3"
        ]
    ),
    snellenChart: SnellenChart(
        sequence: [
            SnellenStep(image: "snellen_E", value: "E"),
            SnellenStep(image: "snellen_J", value: "J")
        ]
    )
)

let mockTestDVA = AcuityTest(
    testType: .NearVision,
    instruction: TestInstruction(
        description: [
            "Place your phone about 2 metres away from you.",
            "Read the letters out loud, then say “Next” to continue.",
            "If your position changes, recalibrate before proceeding.",
            "Make sure the screen is at eye level and well-lit for best accuracy."
        ],
        images: [
            "testInstruction1",
            "testInstruction2",
            "testInstruction3",
            "testInstruction3"
        ]
    ),
    snellenChart: SnellenChart(
        sequence: [
            SnellenStep(image: "snellen_E", value: "E"),
            SnellenStep(image: "snellen_J", value: "J")
        ]
    )
)

let mockTestBlink = BlinkRateTest(
    instructions: TestInstruction(description: [
        "Hold your phone about 40 cm away and sit comfortably.",
        "Blink naturally — don’t try to control or force your blinks.",
        "Keep your head steady with your face clearly visible to the camera.",
        "Relax and normally read the text displayed."
    ], images: ["testInstruction1",
                "testInstruction2",
                "testInstruction3",
                "testInstruction3"]),
    passages: """
        Arjun always took his eyesight for granted. He spent hours scrolling on his phone, studying on his laptop, and gaming late into the night. Slowly, his eyes began to ache, and everything started to look slightly hazy. He ignored it at first, brushing it off as simple tiredness. But one day, while driving, he realized he couldn’t clearly read a road sign until he was dangerously close. That moment scared him enough to finally visit an eye specialist.
        
        The doctor explained that his vision had weakened and warned him about the long-term effects of screen strain. Determined to change, Arjun began following the 20-20-20 rule—every 20 minutes, he looked 20 feet away for 20 seconds. He reduced his screen brightness, took regular breaks, ate more greens, and even started wearing protective glasses. Within weeks, his eyes felt lighter and healthier. He learned an important lesson: caring for your eyes isn’t optional—it’s essential.
        """
)

let calendar = Calendar.current

let blinkRateMockData: [BlinkRateTestResult] = {
    let today = Date()
    var results: [BlinkRateTestResult] = []
    
    // last 28 days (4 weeks)
    for i in 0..<28 {
        guard let date = calendar.date(byAdding: .day, value: -i, to: today) else {
            continue
        }
        
        let blinks = Int.random(in: 28...50) // bpm ~ 14–25
        results.append(
            BlinkRateTestResult(
                id: i,
                blinks: blinks,
                performedOn: date
            )
        )
    }
    
    return results
}()
