
import Foundation
import UIKit

// MARK: - All Exercises (Complete Library)
let allExercises: [Exercise] = [
    Exercise(
        id: 1,
        name: "Palming",
        duration: 120,
        instructions: ExerciseInstruction(
            title: "Palming",
            description: "Rub hands to warm them, close eyes and gently cup palms over them without pressure for 1–3 minutes while breathing slowly.",
            video: "palming"
        ),
        targetedConditions: [.eyeStrain, .dryEyeSyndrome, .lightSensitivity],
        type: .offScreen
    ),
    
    Exercise(
        id: 2,
        name: "Focus Shifting",
        duration: 100,
        instructions: ExerciseInstruction(
            title: "Near-Far Focus",
            description: "Hold a finger 10–12 inches away, focus for 5 seconds, then shift focus to a distant object for 5 seconds. Repeat 10 times.",
            video: "focusShifting"
        ),
        targetedConditions: [.accommodativeDysfunction, .digitalEyeStrain],
        type: .offScreen
    ),
    
    Exercise(
        id: 3,
        name: "Blinking Exercise",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Blinking",
            description: "Blink slowly and fully 10–15 times, then close eyes for 10 seconds.",
            video: "blinking"
        ),
        targetedConditions: [.dryEyeSyndrome],
        type: .offScreen
    ),
    
    Exercise(
        id: 4,
        name: "Eye Rolling",
        duration: 45,
        instructions: ExerciseInstruction(
            title: "Eye Rolling",
            description: "Slowly roll eyes clockwise 5 times and counterclockwise 5 times.",
            video: "eyeRolling"
        ),
        targetedConditions: [.eyeMuscleTension, .eyeFatigue],
        type: .offScreen
    ),
    
    Exercise(
        id: 5,
        name: "Figure 8",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Figure 8 Exercise",
            description: "Imagine a large sideways 8 about 10 feet away and trace it slowly with your eyes for 30 seconds each direction.",
            video: "figure8"
        ),
        targetedConditions: [.generalEyeCoordination, .eyeFatigue],
        type: .offScreen
    ),
    
    Exercise(
        id: 6,
        name: "Zooming Exercise",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Zooming",
            description: "Hold thumb at arm’s length, focus on it, slowly bring it closer to the nose while maintaining focus. Repeat 10 times.",
            video: "zooming"
        ),
        targetedConditions: [.accommodativeDysfunction],
        type: .offScreen
    ),
    
    Exercise(
        id: 7,
        name: "Eye Squeeze",
        duration: 45,
        instructions: ExerciseInstruction(
            title: "Eye Squeeze",
            description: "Close eyes tightly for 3–5 seconds then relax. Repeat 5–7 times.",
            video: "eyeSqueeze"
        ),
        targetedConditions: [.dryEyeSyndrome, .eyeFatigue],
        type: .offScreen
    ),
    
    Exercise(
        id: 8,
        name: "Distance Gazing",
        duration: 120,
        instructions: ExerciseInstruction(
            title: "Distance Gazing",
            description: "Look at a distant object (trees or skyline) for 1–2 minutes without focusing on details.",
            video: "distanceGazing"
        ),
        targetedConditions: [.digitalEyeStrain, .eyeFatigue],
        type: .offScreen
    ),
    
    Exercise(
        id: 9,
        name: "Warm Compress",
        duration: 180,
        instructions: ExerciseInstruction(
            title: "Warm Compress",
            description: "Place a warm cloth over closed eyes for 3–5 minutes.",
            video: "warmCompress"
        ),
        targetedConditions: [.dryEyeSyndrome],
        type: .offScreen
    ),
    
    Exercise(
        id: 10,
        name: "Saccadic Target Chase",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Saccadic Target Chase",
            description: "Watch for shapes that appear randomly on the screen and quickly shift your gaze to each one, holding focus briefly.",
            video: "saccadicChase"
        ),
        targetedConditions: [.eyeFatigue, .accommodativeDysfunction],
        type: .onScreen
    ),

    Exercise(
        id: 11,
        name: "Smooth Pursuit Tracking",
        duration: 120,
        instructions: ExerciseInstruction(
            title: "Smooth Pursuit Tracking",
            description: "Follow a moving dot or ball on the screen with your eyes in all directions for 30 seconds each direction.",
            video: "smoothPursuit"
        ),
        targetedConditions: [.eyeMuscleTension, .smoothPursuitDysfunction],
        type: .onScreen
    ),

    Exercise(
        id: 12,
        name: "Hidden Object Search",
        duration: 90,
        instructions: ExerciseInstruction(
            title: "Hidden Object Search",
            description: "Identify and tap the designated letter or object hidden among other shapes on the screen.",
            video: "hiddenObject"
        ),
        targetedConditions: [.digitalEyeStrain, .eyeFatigue],
        type: .onScreen
    ),

    Exercise(
        id: 13,
        name: "Color Adaptation",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Color Adaptation",
            description: "Identify and tap the odd color among similar colored objects displayed on the screen.",
            video: "colorAdaptation"
        ),
        targetedConditions: [.visualStress, .digitalEyeStrain],
        type: .onScreen
    )
]

struct ExerciseInfoType {
    let icon: String
    let bgColor: UIColor
    let iconBGColor: UIColor
    let storyboardName: String
    let storyboardID: String
    let exerciseData: [ExerciseStage]
    let impact: String
}

let defaultStoryboardName = "Figure8"
let defaultStoryboardID = "Figure8ViewController"

let ExerciseInfo: [Int: ExerciseInfoType] = [

    1: ExerciseInfoType(
        icon: "Brock", // TODO: add Palming icon
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "5BC8A8"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Rub hands together to warm them.", duration: 15),
            ExerciseStage(instruction: "Close eyes and gently cup palms over them without pressure.", duration: 90),
            ExerciseStage(instruction: "Relax and breathe slowly.", duration: 15)
        ],
        impact: "Relaxes eye muscles and reduces fatigue"
    ),

    2: ExerciseInfoType(
        icon: "Focus Shifting",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "6FAEFF"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Focus on finger 10–12 inches away.", duration: 5),
            ExerciseStage(instruction: "Shift focus to distant object.", duration: 5)
        ],
        impact: "Improves focusing flexibility and reduces stiffness"
    ),

    3: ExerciseInfoType(
        icon: "Guided Blinking",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "A68BEB"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Blink slowly and fully 15 times.", duration: 20),
            ExerciseStage(instruction: "Close eyes and relax.", duration: 10)
        ],
        impact: "Improves tear distribution and prevents dryness"
    ),

    4: ExerciseInfoType(
        icon: "Roll",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "F5B942"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Roll eyes clockwise 5 times.", duration: 15),
            ExerciseStage(instruction: "Roll eyes counterclockwise 5 times.", duration: 15)
        ],
        impact: "Relaxes extraocular muscles and improves mobility"
    ),

    5: ExerciseInfoType(
        icon: "Infinity",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "E66A7A"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Trace sideways 8 clockwise.", duration: 30),
            ExerciseStage(instruction: "Trace sideways 8 counterclockwise.", duration: 30)
        ],
        impact: "Improves eye coordination and control"
    ),

    6: ExerciseInfoType(
        icon: "Zoom",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "FF9C66"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Focus on thumb at arm’s length.", duration: 5),
            ExerciseStage(instruction: "Slowly bring thumb closer while maintaining focus.", duration: 10),
            ExerciseStage(instruction: "Move thumb back to arm’s length.", duration: 5)
        ],
        impact: "Strengthens focusing ability"
    ),

    7: ExerciseInfoType(
        icon: "Brock", // TODO: add Eye Squeeze icon
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "4DB6C6"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Close eyes tightly.", duration: 5),
            ExerciseStage(instruction: "Relax eyes.", duration: 5)
        ],
        impact: "Stimulates tear glands and relaxes muscles"
    ),

    8: ExerciseInfoType(
        icon: "Peripheral Focus",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "6B7CFF"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Look at a distant object without focusing on details.", duration: 120)
        ],
        impact: "Relaxes focusing muscles"
    ),

    9: ExerciseInfoType(
        icon: "Brock", // TODO: add Warm Compress icon
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "7FD16A"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Place warm cloth over closed eyes and relax.", duration: 180)
        ],
        impact: "Improves oil gland function and tear stability"
    ),

    10: ExerciseInfoType(
        icon: "Saccadic Movement",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "FF7DB0"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [],
        impact: "Improves saccadic speed and eye movement accuracy, enhances visual scanning"
    ),

    11: ExerciseInfoType(
        icon: "Smooth Pursuit",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "9BC53D"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [],
        impact: "Strengthens continuous eye tracking and coordination"
    ),

    12: ExerciseInfoType(
        icon: "Brock",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "D1495B"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [],
        impact: "Exercises visual search and attention, disperses focus to reduce fixation strain"
    ),

    13: ExerciseInfoType(
        icon: "Color Contrast",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "2E4057"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [],
        impact: "Improves color discrimination and visual processing flexibility"
    )
]
