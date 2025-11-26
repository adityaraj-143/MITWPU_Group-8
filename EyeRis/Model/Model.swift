//
//  Model.swift
//  EyeRis
//
//  Created by SDC-USER on 24/11/25.
//

import Foundation

struct User{
    var firstName: String
    var lastName: String
    var gender: String
    var dob: Date
    var eyeHealthData: UserEyeHealthData
}

struct UserEyeHealthData{
    // Store all the onboarding data
    // also extra data if needed
    var condition: [Conditions] // think about this, if this has to be here on in userdata
}

struct Exercise{
    var id: Int
    var name: String
    var duration: Int
    var instructions: ExerciseInstruction
    var condition : [Conditions]
}

struct ExerciseInstruction{
    var title: String
    var description: [String]
    var video: String
}

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

enum Conditions{ // more conditions to be added, research needed
    case dryEyes
    case eyeFatigue
    case blurredVision
    case wateryEyes
}

struct EyeTips{
    var tip: String
    var condition: [Conditions]
}

struct PerformedExerciseStat {
    var id: Int
    var name: String
    var performedOn: Date
    var accuracy: Int
    var speed: Int
}

struct AcuityScore{ // need to change this (research needed)
    var temp: String
    
    func calcScore () {
        // should return the score of the test
    }
}

struct AcuityTest{
    // put the details for the snellen chart, and respective score details in the score struct
//    var id: Int
//    var leftEyeScore: AcuityScore
}

struct BlinkRateTest{
    var instructions: TestInstruction
    var passages: [String]
    var duration: Int = 120
}

struct TestInstruction{
//    var title: String
    var description: [String]
    var images: [String]
}


