import Foundation

//MARK: TEST RESULTS
// Dummy data for Test Results
let dummyAcuityResults: [AcuityTestResult] = [
    // Jan 10 (Reduced + imbalance)
    AcuityTestResult(
        id: 1001,
        testType: .nearVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 10))!,
        healthyScore: "20/20",
        leftEyeScore: "20/60",
        rightEyeScore: "20/25"
    ),
    
    AcuityTestResult(
        id: 1002,
        testType: .distantVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 10))!,
        healthyScore: "20/20",
        leftEyeScore: "20/80",
        rightEyeScore: "20/30"
    ),
    
    // Feb 3 (Good + near-distance mismatch)
    AcuityTestResult(
        id: 2001,
        testType: .nearVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 3))!,
        healthyScore: "20/20",
        leftEyeScore: "20/20",
        rightEyeScore: "20/20"
    ),
    
    AcuityTestResult(
        id: 2002,
        testType: .distantVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 3))!,
        healthyScore: "20/20",
        leftEyeScore: "20/40",
        rightEyeScore: "20/40"
    ),
    
    // March 15 (Severe)
    AcuityTestResult(
        id: 3001,
        testType: .nearVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 15))!,
        healthyScore: "20/20",
        leftEyeScore: "20/100",
        rightEyeScore: "20/80"
    ),
    
    AcuityTestResult(
        id: 3002,
        testType: .distantVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 15))!,
        healthyScore: "20/20",
        leftEyeScore: "20/200",
        rightEyeScore: "20/100"
    ),
    
    // April 5 (Excellent)
    AcuityTestResult(
        id: 4001,
        testType: .nearVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 4, day: 5))!,
        healthyScore: "20/20",
        leftEyeScore: "20/20",
        rightEyeScore: "20/15"
    ),
    
    AcuityTestResult(
        id: 4002,
        testType: .distantVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 4, day: 5))!,
        healthyScore: "20/20",
        leftEyeScore: "20/20",
        rightEyeScore: "20/20"
    ),
    
    // May 12 (Balanced reduced, no imbalance)
    AcuityTestResult(
        id: 5001,
        testType: .nearVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 5, day: 12))!,
        healthyScore: "20/20",
        leftEyeScore: "20/60",
        rightEyeScore: "20/60"
    ),
    
    AcuityTestResult(
        id: 5002,
        testType: .distantVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 5, day: 12))!,
        healthyScore: "20/20",
        leftEyeScore: "20/60",
        rightEyeScore: "20/60"
    ),
    
    // June 8 (Imbalance only, otherwise good)
    AcuityTestResult(
        id: 6001,
        testType: .nearVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 6, day: 8))!,
        healthyScore: "20/20",
        leftEyeScore: "20/20",
        rightEyeScore: "20/40"
    ),
    
    AcuityTestResult(
        id: 6002,
        testType: .distantVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 6, day: 8))!,
        healthyScore: "20/20",
        leftEyeScore: "20/25",
        rightEyeScore: "20/40"
    ),
    
    // July 1 (Mild good case)
    AcuityTestResult(
        id: 7001,
        testType: .nearVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: 1))!,
        healthyScore: "20/20",
        leftEyeScore: "20/25",
        rightEyeScore: "20/30"
    ),
    
    AcuityTestResult(
        id: 7002,
        testType: .distantVision,
        testDate: Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: 1))!,
        healthyScore: "20/20",
        leftEyeScore: "20/30",
        rightEyeScore: "20/30"
    )
]



let mockTestNVA = AcuityTest(
    testType: .nearVision,
    instruction: TestInstruction(
        description: [
            "This is a Near Vision Test — place your phone about 40 cm away from you.",
            "Read the letters out loud, then say “Next” to move forward.",
            "If your phone position changes, then pause the test and recalibrate to adjust.",
            "Make sure the screen is at eye level and well-lit for best accuracy."
        ],
        images: [
            "NVATestInstruction1",
            "NVATestInstruction2",
            "NVATestInstruction3",
            "NVATestInstruction4"
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
    testType: .distantVision,
    instruction: TestInstruction(
        description: [
            "This is a Distant Vision Test — keep your phone about 2 metres away from your eyes.",
            "Read the letters out loud, then say “Next” to continue.",
            "If your position changes, then pause the test and recalibrate before proceeding.",
            "Make sure the screen is at eye level and well-lit for best accuracy."
        ],
        images: [
            "DVATestInstruction1",
            "NVATestInstruction2",
            "NVATestInstruction3",
            "NVATestInstruction4"
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
    ], images: ["NVATestInstruction1",
                "BlinkTestInstruction2",
                "BlinkTestInstruction3",
                "NVATestInstruction4"]),
    passages: passages.randomElement() ?? "passage not loaded",
    duration: 30
)


