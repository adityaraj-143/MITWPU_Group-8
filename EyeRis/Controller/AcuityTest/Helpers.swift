//
//  Utils.swift
//  EyeRis
//
//  Created by SDC-USER on 23/01/26.
//

import CoreFoundation


let fontSizes: [CGFloat] = [
    176.0, // 20/200
    88.0,  // 20/100
    70.0,  // 20/80
    53.0,  // 20/60
    35.0,  // 20/40
    26.0,  // 20/30
    22.0,  // 20/25
    18.0,  // 20/20
    13.0
]
let NVAFontSizes: [CGFloat] = [
    35.0,  // 20/200
    18.0,  // 20/100
    14.0,  // 20/80
    11.0,  // 20/60
    7.0,   // 20/40
    5.3,   // 20/30
    4.4,   // 20/25
    3.5,   // 20/20
    2.6    // 20/15
]
let DVAFontSizes: [CGFloat] = [
    176.0, // 20/200
    88.0,  // 20/100
    70.0,  // 20/80
    53.0,  // 20/60
    35.0,  // 20/40
    26.0,  // 20/30
    22.0,  // 20/25
    18.0,  // 20/20
    13.0   // 20/15
]

func generateRandomLetters(count: Int) -> String {
    let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return String((0..<count).map { _ in letters.randomElement()! })
}
