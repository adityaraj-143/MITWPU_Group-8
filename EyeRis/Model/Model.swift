//
//  Model.swift
//  EyeRis
//
//  Created by SDC-USER on 24/11/25.
//

import Foundation

enum Conditions {
    case digitalEyeStrain
    case dryEyeSyndrome
    case eyeFatigue
    case eyeMuscleTension
    case eyeStress
    case lightSensitivity
    case visualStress
    case accommodativeDysfunction
    case saccadicDysfunction
    case convergenceInsufficiency
    case smoothPursuitDysfunction
    case generalEyeCoordination
    case dryEyes

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
        }
    }
}



//MARK: COMMENT & TIP
// to get the comment for either test or exercise based on the details passed as params
struct Comment {
    var exerciseComments: [String]
    var testComments: [String]
    
    func getComment(accuracy: Int, speed: Int) -> String{
        
        return exerciseComments[Int.random(in: 0..<exerciseComments.count)]
    }
    
    func getComment(testScore: [Int]) -> String {
        return testComments[Int.random(in: 0..<testComments.count)]
    }
}

struct EyeTips{
    var tip: String
    var condition: [Conditions]
}



//MARK: DATE HELPER
// Helper to create a Date like makeDate(year: 2025, month: 5, day: 8)
func makeDate(year: Int, month: Int, day: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    return Calendar.current.date(from: components) ?? Date()
}


