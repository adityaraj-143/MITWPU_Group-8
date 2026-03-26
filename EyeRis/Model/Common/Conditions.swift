//
//  Conditions.swift
//  EyeRis
//
//  Created by SDC-USER on 24/11/25.
//

import Foundation

enum Conditions: String {
    case digitalEyeStrain = "digitalEyeStrain"
    case dryEyeSyndrome = "dryEyeSyndrome"
    case eyeFatigue = "eyeFatigue"
    case eyeMuscleTension = "eyeMuscleTension"
    case eyeStress = "eyeStress"
    case lightSensitivity = "lightSensitivity"
    case visualStress = "visualStress"
    case accommodativeDysfunction = "accommodativeDysfunction"
    case saccadicDysfunction = "saccadicDysfunction"
    case convergenceInsufficiency = "convergenceInsufficiency"
    case smoothPursuitDysfunction = "smoothPursuitDysfunction"
    case generalEyeCoordination = "generalEyeCoordination"
    case dryEyes = "dryEyes"
    case eyeStrain = "eyeStrain"
    case oculomotorDysfunction = "oculomotorDysfunction"

    /// Human-readable text for UI
    var displayText: String {
        switch self {
        case .digitalEyeStrain: return "Digital Eye Strain"
        case .dryEyeSyndrome: return "Dry Eye Syndrome"
        case .eyeFatigue: return "Eye Fatigue"
        case .eyeMuscleTension: return "Eye Muscle Tension"
        case .eyeStress: return "Eye Stress"
        case .lightSensitivity: return "Light Sensitivity"
        case .visualStress: return "Visual Stress / Contrast Sensitivity"
        case .accommodativeDysfunction: return "Accommodative Dysfunction"
        case .saccadicDysfunction: return "Saccadic Movement Dysfunction"
        case .convergenceInsufficiency: return "Convergence Insufficiency"
        case .smoothPursuitDysfunction: return "Smooth Pursuit Dysfunction"
        case .generalEyeCoordination: return "General Eye Coordination"
        case .dryEyes: return "Dry eyes"
        case .eyeStrain: return "Eye Strain"
        case .oculomotorDysfunction: return "Oculomotor Dysfunction"
        }
    }
}

// MARK: - Comment & Tip

/// Get comment for either test or exercise based on the details passed as params
struct Comment {
    var exerciseComments: [String]
    var testComments: [String]
    
    func getComment(accuracy: Int, speed: Int) -> String {
        return exerciseComments[Int.random(in: 0..<exerciseComments.count)]
    }
    
    func getComment(testScore: [Int]) -> String {
        return testComments[Int.random(in: 0..<testComments.count)]
    }
}
