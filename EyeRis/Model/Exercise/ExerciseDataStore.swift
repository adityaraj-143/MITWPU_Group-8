
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

struct ExerciseCardInfo {
    let icon: String
    let bgColor: UIColor
    let iconBGColor: UIColor
    let storyboardName: String
    let storyboardID: String
    
//    let vcType: UIViewController.Type
}

let defaultStoryboardName = "Figure8"
let defaultStoryboardID = "Figure8ViewController"
//let defaultVCType = Figure8ViewController

let ExerciseInfo: [Int: ExerciseCardInfo] = [
    
    1: ExerciseCardInfo(
        icon: "20",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "5BC8A8"), // kept
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),
    
    2: ExerciseCardInfo(
        icon: "Guided Blinking",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "6FAEFF"), // kept
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),
    
    3: ExerciseCardInfo(
        icon: "Infinity",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "A68BEB"), // kept
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),
    
    4: ExerciseCardInfo(
        icon: "Roll",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "F5B942"), // kept
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),
    
    5: ExerciseCardInfo(
        icon: "Peripheral Focus",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "E66A7A"), // kept
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),
    
    6: ExerciseCardInfo(
        icon: "Light Adaption",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "FF9C66"), // kept
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),
    
    7: ExerciseCardInfo(
        icon: "Color Contrast",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "4DB6C6"), // unique already
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),
    
    8: ExerciseCardInfo(
        icon: "Focus Shifting",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "6B7CFF"), // unique already
        storyboardName: "FocusShifting",
        storyboardID: "FocusShiftingViewController"
    ),
    
    9: ExerciseCardInfo(
        icon: "Zoom",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "7FD16A"), // NEW
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),
    
    10: ExerciseCardInfo(
        icon: "Saccadic Movement",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "FF7DB0"), // NEW
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),
    
    11: ExerciseCardInfo(
        icon: "Convergence",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "9BC53D"), // Olive Green
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),

    12: ExerciseCardInfo(
        icon: "Brock",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "D1495B"), // Brick Red
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),

    13: ExerciseCardInfo(
        icon: "Smooth Pursuit",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "2E4057"), // Slate Blue-Grey
        storyboardName: "SmoothPursuit",
        storyboardID: "SmoothPursuitViewController"
    ),

    14: ExerciseCardInfo(
        icon: "Eye Movement",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "F4D35E"), // Soft Gold
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    )

]

