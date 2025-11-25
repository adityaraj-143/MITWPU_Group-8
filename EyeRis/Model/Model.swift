//
//  Model.swift
//  EyeRis
//
//  Created by SDC-USER on 24/11/25.
//

struct ExerciseInstruction{
    var title: String
    var description: [String]
    var video: String
}

struct Exercise{
    var id: Int
    var name: String
    var duration: Int
    var instructions: ExerciseInstruction
    var condition : [Conditions]
}

enum Conditions{ // more conditions to be added, research needed
    case dryEyes
    case eyeFatigue
    case blurredVision
    case wateryEyes
}
