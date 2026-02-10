//
//  ExerciseMockDataStore.swift
//  EyeRis
//
//  Created by SDC-USER on 12/12/25.
//

import Foundation
import UIKit
//MARK: EXERCISE HISTORY
// Dummy data for Exercise History

let mockPerformedExerciseStats: [PerformedExerciseStat] = [
    // Today (2 exercises → 90+ avg)
    PerformedExerciseStat(id: 1, name: "Eye Focus Drill", performedOn: Date(), accuracy: 94, speed: 91),
    PerformedExerciseStat(id: 2, name: "Blink Control", performedOn: Date(), accuracy: 92, speed: 90),
    
    // 2 days ago (3 exercises → 80+ avg)
    PerformedExerciseStat(id: 3, name: "Peripheral Vision", performedOn: Date(timeIntervalSinceNow: -2*24*60*60), accuracy: 86, speed: 82),
    PerformedExerciseStat(id: 4, name: "Eye Tracking", performedOn: Date(timeIntervalSinceNow: -2*24*60*60), accuracy: 84, speed: 80),
    PerformedExerciseStat(id: 5, name: "Near-Far Focus", performedOn: Date(timeIntervalSinceNow: -2*24*60*60), accuracy: 85, speed: 81),
    
    // 4 days ago (1 exercise → <75)
    PerformedExerciseStat(id: 6, name: "Color Recognition", performedOn: Date(timeIntervalSinceNow: -4*24*60*60), accuracy: 73, speed: 70),
    
    // 7 days ago (4 exercises → 80+ avg)
    PerformedExerciseStat(id: 7, name: "Eye Focus Drill", performedOn: Date(timeIntervalSinceNow: -7*24*60*60), accuracy: 88, speed: 84),
    PerformedExerciseStat(id: 8, name: "Blink Control", performedOn: Date(timeIntervalSinceNow: -7*24*60*60), accuracy: 85, speed: 82),
    PerformedExerciseStat(id: 9, name: "Peripheral Vision", performedOn: Date(timeIntervalSinceNow: -7*24*60*60), accuracy: 86, speed: 83),
    PerformedExerciseStat(id: 10, name: "Eye Tracking", performedOn: Date(timeIntervalSinceNow: -7*24*60*60), accuracy: 84, speed: 81),
    
    // 9 days ago (2 exercises → <75 avg)
    PerformedExerciseStat(id: 11, name: "Near-Far Focus", performedOn: Date(timeIntervalSinceNow: -9*24*60*60), accuracy: 74, speed: 71),
    PerformedExerciseStat(id: 12, name: "Blink Control", performedOn: Date(timeIntervalSinceNow: -9*24*60*60), accuracy: 72, speed: 69),
    
    
    // 14 days ago (5 exercises → 90+ avg)
    PerformedExerciseStat(id: 13, name: "Eye Focus Drill", performedOn: Date(timeIntervalSinceNow: -14*24*60*60), accuracy: 93, speed: 91),
    PerformedExerciseStat(id: 14, name: "Blink Control", performedOn: Date(timeIntervalSinceNow: -14*24*60*60), accuracy: 92, speed: 90),
    PerformedExerciseStat(id: 15, name: "Peripheral Vision", performedOn: Date(timeIntervalSinceNow: -14*24*60*60), accuracy: 94, speed: 92),
    PerformedExerciseStat(id: 16, name: "Near-Far Focus", performedOn: Date(timeIntervalSinceNow: -14*24*60*60), accuracy: 91, speed: 89),
    PerformedExerciseStat(id: 17, name: "Eye Tracking", performedOn: Date(timeIntervalSinceNow: -14*24*60*60), accuracy: 93, speed: 90),
    
    // 16 days ago (1 exercise → 80+)
    PerformedExerciseStat(id: 18, name: "Color Recognition", performedOn: Date(timeIntervalSinceNow: -16*24*60*60), accuracy: 82, speed: 79),
    
    // 21 days ago (6 exercises → <75 avg)
    PerformedExerciseStat(id: 19, name: "Eye Focus Drill", performedOn: Date(timeIntervalSinceNow: -21*24*60*60), accuracy: 74, speed: 70),
    PerformedExerciseStat(id: 20, name: "Blink Control", performedOn: Date(timeIntervalSinceNow: -21*24*60*60), accuracy: 73, speed: 69),
    PerformedExerciseStat(id: 21, name: "Peripheral Vision", performedOn: Date(timeIntervalSinceNow: -21*24*60*60), accuracy: 72, speed: 68),
    PerformedExerciseStat(id: 22, name: "Near-Far Focus", performedOn: Date(timeIntervalSinceNow: -21*24*60*60), accuracy: 71, speed: 67),
    PerformedExerciseStat(id: 23, name: "Eye Tracking", performedOn: Date(timeIntervalSinceNow: -21*24*60*60), accuracy: 73, speed: 69),
    PerformedExerciseStat(id: 24, name: "Color Recognition", performedOn: Date(timeIntervalSinceNow: -21*24*60*60), accuracy: 72, speed: 68),
    
    // 23 days ago (3 exercises → 80+ avg)
    PerformedExerciseStat(id: 25, name: "Eye Focus Drill", performedOn: Date(timeIntervalSinceNow: -23*24*60*60), accuracy: 85, speed: 82),
    PerformedExerciseStat(id: 26, name: "Blink Control", performedOn: Date(timeIntervalSinceNow: -23*24*60*60), accuracy: 87, speed: 83),
    PerformedExerciseStat(id: 27, name: "Peripheral Vision", performedOn: Date(timeIntervalSinceNow: -23*24*60*60), accuracy: 84, speed: 81)
]

// MARK: - All Exercises (Complete Library)

let allExercises: [Exercise] = [
    
    Exercise(
        id: 1,
        name: "20-20-20",
        duration: 20,
        instructions: ExerciseInstruction(
            title: "20-20-20 Rule",
            description: "Every 20 minutes, look at a point 20 feet away for 20 seconds.",
            video: "figure8"
        ),
        targetedConditions: [.digitalEyeStrain]
    ),
    
    Exercise(
        id: 2,
        name: "Guided Blinking",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Blinking Exercise",
            description: "Follow visual or audio cues to perform complete blinks at set intervals.",
            video: "FocusShifting"
        ),
        targetedConditions: [.dryEyeSyndrome]
    ),
    
    Exercise(
        id: 3,
        name: "Figure 8",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Figure 8",
            description: "Track a moving dot following a figure-8 pattern on screen.",
            video: "figure8"
        ),
        targetedConditions: [.eyeFatigue]
    ),
    
    Exercise(
        id: 4,
        name: "Eye Rolling",
        duration: 45,
        instructions: ExerciseInstruction(
            title: "Eye Rolling",
            description: "Rotate eyes slowly in clockwise and counterclockwise circles.",
            video: "FocusShifting"
        ),
        targetedConditions: [.eyeMuscleTension]
    ),
    
    Exercise(
        id: 5,
        name: "Peripheral Vision",
        duration: 120,
        instructions: ExerciseInstruction(
            title: "Peripheral Vision",
            description: "Cover closed eyes with palms and follow guided breathing.",
            video: "FocusShifting"
        ),
        targetedConditions: [.eyeStress, .eyeFatigue]
    ),
    
    Exercise(
        id: 6,
        name: "Light Adaptation",
        duration: 90,
        instructions: ExerciseInstruction(
            title: "Light Adaptation",
            description: "Gradually adjust screen brightness to train light tolerance.",
            video: "figure8"
        ),
        targetedConditions: [.lightSensitivity]
    ),
    
    Exercise(
        id: 7,
        name: "Color Contrast",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Color Contrast",
            description: "View varying color and contrast combinations.",
            video: "figure8"
        ),
        targetedConditions: [.visualStress]
    ),
    
    Exercise(
        id: 8,
        name: "Focus Shifting",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Near Far Focus",
            description: "Alternate focus between near and far targets.",
            video: "FocusShifting"
        ),
        targetedConditions: [.accommodativeDysfunction]
    ),
    
    Exercise(
        id: 9,
        name: "Zooming Exercise",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Zooming",
            description: "Follow objects that expand and contract in size.",
            video: "figure8"
        ),
        targetedConditions: [.accommodativeDysfunction]
    ),
    
    Exercise(
        id: 10,
        name: "Saccadic Movement",
        duration: 45,
        instructions: ExerciseInstruction(
            title: "Saccadic Movements",
            description: "Shift gaze rapidly between targets on screen.",
            video: "smoothPursuit"
        ),
        targetedConditions: [.saccadicDysfunction]
    ),
    
    Exercise(
        id: 11,
        name: "Convergence Drill",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Convergence",
            description: "Follow a virtual object moving toward and away.",
            video: "smoothPursuit"
        ),
        targetedConditions: [.convergenceInsufficiency]
    ),
    
    Exercise(
        id: 12,
        name: "Brock String",
        duration: 90,
        instructions: ExerciseInstruction(
            title: "Brock String",
            description: "Focus sequentially on virtual beads at varying depths.",
            video: "smoothPursuit"
        ),
        targetedConditions: [.convergenceInsufficiency]
    ),
    
    Exercise(
        id: 13,
        name: "Smooth Pursuit",
        duration: 60,
        instructions: ExerciseInstruction(
            title: "Smooth Pursuit",
            description: "Follow slowly moving objects across the screen.",
            video: "smoothPursuit"
        ),
        targetedConditions: [.smoothPursuitDysfunction]
    ),
    
    Exercise(
        id: 14,
        name: "Eye Movement",
        duration: 120,
        instructions: ExerciseInstruction(
            title: "Eye Games",
            description: "Play gamified tasks requiring specific eye movements.",
            video: "smoothPursuit"
        ),
        targetedConditions: [.generalEyeCoordination, .eyeFatigue]
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
    
    // 🔁 second occurrence → replaced
    9: ExerciseCardInfo(
        icon: "Zoom",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "7FD16A"), // NEW
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),
    
    // 🔁 second occurrence → replaced
    10: ExerciseCardInfo(
        icon: "Saccadic Movement",
        bgColor: UIColor(hex: "FFFFFF"),
        iconBGColor: UIColor(hex: "FF7DB0"), // NEW
        storyboardName: defaultStoryboardName,
        storyboardID: defaultStoryboardID
    ),
    
    // 🔁 second occurrence → replaced
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

