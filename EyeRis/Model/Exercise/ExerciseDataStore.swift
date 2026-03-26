
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
            video: "farjadPalming"
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
            video: "farjadFocusShift"
        ),
        targetedConditions: [.accommodativeDysfunction, .digitalEyeStrain],
        type: .offScreen
    ),
    
    Exercise(
        id: 3,
        name: "Rapid Blinking",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Blinking",
            description: "Blink fast 10–15 times, then close eyes for 10 seconds.",
            video: "farjadBlinking" //placeholder
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
            video: "farjadEyeRolling" //placeholder
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
            video: "farjadFig8"
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
            video: "farjadZooming" //placeholder
        ),
        targetedConditions: [.accommodativeDysfunction],
        type: .offScreen
    ),
    
    Exercise(
        id: 7,
        name: "Slow Blinking",
        duration: 45,
        instructions: ExerciseInstruction(
            title: "Eye Squeeze",
            description: "Close eyes tightly then relax. Repeat 5–7 times.",
            video: "farjadEyeSqueeze" //placehoder
        ),
        targetedConditions: [.dryEyeSyndrome, .eyeFatigue],
        type: .offScreen
    ),
    
    Exercise(
        id: 8,
        name: "Vertical Movement",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Up–Down Eye Movement",
            description: "Keep your head still. Move your eyes quickly from top to bottom. Repeat continuously without straining.",
            video: "farjadEyeSqueeze"
        ),
        targetedConditions: [.eyeFatigue, .oculomotorDysfunction, .digitalEyeStrain],
        type: .offScreen
    ),

    Exercise(
        id: 9,
        name: "Horizontal Movement",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Left–Right Eye Movement",
            description: "Keep your head still. Move your eyes quickly from left to right. Repeat continuously without straining.",
            video: "farjadEyeSqueeze"
        ),
        targetedConditions: [.eyeFatigue, .oculomotorDysfunction, .digitalEyeStrain],
        type: .offScreen
    ),
    
    Exercise(
        id: 10,
        name: "Thumb Focus",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Head Rotation with Thumb Focus",
            description: "Extend your arm and focus on your thumb. Slowly rotate your head left and right while keeping your eyes fixed on your thumb.",
            video: "farjadEyeSqueeze"
        ),
        targetedConditions: [.eyeFatigue, .digitalEyeStrain],
        type: .offScreen
    ),


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
        icon: "Palming", // TODO: add Palming icon
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "5BC8A8"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Rub hands together to warm them.", duration: 5),//15
            ExerciseStage(instruction: "Close eyes and gently cup palms over them without pressure.", duration: 5),//90
            ExerciseStage(instruction: "Relax and breathe slowly.", duration: 5)//15
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
            ExerciseStage(instruction: "Trace sideways 8 clockwise.", duration: 5), //30
            ExerciseStage(instruction: "Trace sideways 8 counterclockwise.", duration: 5) //30
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
        icon: "Eye Squeeze", // TODO: add Eye Squeeze icon
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
        icon:  "Vertical Movement",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "4CAF50"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Look straight ahead. Keep your head still.", duration: 5),
            ExerciseStage(instruction: "Move your eyes up.", duration: 5),
            ExerciseStage(instruction: "Move your eyes down.", duration: 5),
            ExerciseStage(instruction: "Repeat up and down movement continuously.", duration: 45)
        ],
        impact: "Improves vertical eye control and strengthens oculomotor coordination"
    ),

    9: ExerciseInfoType(
        icon:  "Horizontal Movement",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "FF9800"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Look straight ahead. Keep your head still.", duration: 5),
            ExerciseStage(instruction: "Move your eyes to the left.", duration: 5),
            ExerciseStage(instruction: "Move your eyes to the right.", duration: 5),
            ExerciseStage(instruction: "Repeat left and right movement continuously.", duration: 45)
        ],
        impact: "Enhances horizontal tracking and improves eye movement speed"
    ),
    
    10: ExerciseInfoType(
        icon:  "Thumb Focus",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "8E44AD"),
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID,
        exerciseData: [
            ExerciseStage(instruction: "Extend your arm and focus on your thumb.", duration: 5),
            ExerciseStage(instruction: "Slowly rotate your head to the left while keeping focus on your thumb.", duration: 10),
            ExerciseStage(instruction: "Slowly rotate your head to the right while keeping focus on your thumb.", duration: 10),
            ExerciseStage(instruction: "Continue rotating left and right while maintaining focus.", duration: 35)
        ],
        impact: "Improves eye-head coordination and stabilizes gaze during head movement"
    ),

]
