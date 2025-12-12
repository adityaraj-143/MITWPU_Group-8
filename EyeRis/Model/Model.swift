//
//  Model.swift
//  EyeRis
//
//  Created by SDC-USER on 24/11/25.
//

import Foundation


// MARK: USER DETAILS
struct User{
    var firstName: String
    var lastName: String
    var gender: String
    var dob: Date
    var eyeHealthData: UserEyeHealthData
}

struct UserEyeHealthData{
    // Store all the onboarding data
    // the eye conditions that the user is facing
    var condition: [Conditions] // think about this, if this has to be here on in userdata
    
    func getUserEyeConditions() -> [Conditions]{
        var conditions: [Conditions] = []
        return conditions
    }
}

enum Conditions{ // more conditions to be added, research needed
    case dryEyes
    case eyeFatigue
    case blurredVision
    case wateryEyes
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


