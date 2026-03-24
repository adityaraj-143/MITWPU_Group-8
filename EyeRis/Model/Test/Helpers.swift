import Foundation

func calcAcuityScore(level: Int) -> String {
    
    let snellenMap = [
        "20/200",
        "20/100",
        "20/80",
        "20/60",
        "20/40",
        "20/30",
        "20/25",
        "20/20",
        "20/15"
    ]
    
    guard level >= 0 && level < snellenMap.count else {
        return "N/A"
    }
    
    return snellenMap[level]
}

func acuityValue(_ acuity: String) -> Int {
    let parts = acuity.split(separator: "/")
    return parts.count == 2 ? Int(parts[1]) ?? 999 : 999
}

func category(_ value: Int) -> Int {
    switch value {
    case ...20: return 0   // excellent
    case 21...40: return 1 // good
    case 41...80: return 2 // reduced
    default: return 3      // poor
    }
}

func getComment(nvaLE: String, nvaRE: String, dvaLE: String, dvaRE: String) -> String {
    
    let nvaL = acuityValue(nvaLE)
    let nvaR = acuityValue(nvaRE)
    let dvaL = acuityValue(dvaLE)
    let dvaR = acuityValue(dvaRE)
    
    let values = [nvaL, nvaR, dvaL, dvaR]
    let worst = values.max() ?? 999
    
    let worstCategory = category(worst)
    
    let eyeDiff = abs(nvaL - nvaR) > 20 || abs(dvaL - dvaR) > 20
    
    let nearAvg = (nvaL + nvaR) / 2
    let distAvg = (dvaL + dvaR) / 2
    let nearDistDiff = abs(nearAvg - distAvg) > 20
    
    // Severe case
    if worstCategory == 3 {
        return "Your vision results show significant reduction in clarity across one or more areas, and a comprehensive eye examination by an ophthalmologist is strongly recommended."
    }
    
    // Reduced vision with imbalance
    if worstCategory == 2 && eyeDiff {
        return "Your vision shows reduced clarity along with a noticeable difference between your eyes, so a detailed eye check-up is recommended to assess and address this imbalance."
    }
    
    // Reduced vision with near-distance mismatch
    if worstCategory == 2 && nearDistDiff {
        return "Your vision indicates reduced clarity with a difference between near and distance focus, so a routine eye examination may help determine if corrective lenses are needed."
    }
    
    // Reduced vision overall
    if worstCategory == 2 {
        return "Your vision shows noticeable reduction in clarity overall, and a routine eye check-up or corrective lenses may help improve visual sharpness in daily activities."
    }
    
    // Imbalance only
    if eyeDiff {
        return "Your vision is generally good, but there is a noticeable difference between your eyes, so a routine eye check-up is advised to maintain balanced visual performance."
    }
    
    // Near vs distance mismatch
    if nearDistDiff {
        return "Your vision is fairly good overall, but there is a difference between near and distance clarity, so minor correction or a routine eye check-up may be beneficial."
    }
    
    // Good vision
    if worstCategory == 1 {
        return "Overall, your vision is fairly good, but a routine eye check-up or corrective lens may help improve clarity, especially for distance vision."
    }
    
    // Excellent vision
    return "Your vision is excellent across both near and distance ranges, and no immediate corrective measures appear necessary, though regular eye check-ups are still recommended."
}

func getTrimmedComment(nvaLE: String, nvaRE: String, dvaLE: String, dvaRE: String) -> String {
    
    func acuityValue(_ acuity: String) -> Int {
        let parts = acuity.split(separator: "/")
        return parts.count == 2 ? Int(parts[1]) ?? 999 : 999
    }
    
    func category(_ value: Int) -> Int {
        switch value {
        case ...20: return 0
        case 21...40: return 1
        case 41...80: return 2
        default: return 3
        }
    }
    
    let nvaL = acuityValue(nvaLE)
    let nvaR = acuityValue(nvaRE)
    let dvaL = acuityValue(dvaLE)
    let dvaR = acuityValue(dvaRE)
    
    let values = [nvaL, nvaR, dvaL, dvaR]
    let worst = values.max() ?? 999
    let worstCategory = category(worst)
    
    let eyeDiff = abs(nvaL - nvaR) > 20 || abs(dvaL - dvaR) > 20
    
    let nearAvg = (nvaL + nvaR) / 2
    let distAvg = (dvaL + dvaR) / 2
    let nearDistDiff = abs(nearAvg - distAvg) > 20
    
    // Severe
    if worstCategory == 3 {
        return "Your vision appears significantly reduced. Consult an ophthalmologist soon for a detailed evaluation."
    }
    
    // Reduced + imbalance
    if worstCategory == 2 && eyeDiff {
        return "Your vision shows reduced clarity with imbalance between eyes. A detailed eye check-up is recommended."
    }
    
    // Reduced + near-distance mismatch
    if worstCategory == 2 && nearDistDiff {
        return "Your vision shows reduced clarity with near-distance differences. A routine eye check-up may help."
    }
    
    // Reduced overall
    if worstCategory == 2 {
        return "Your vision shows reduced clarity overall. A routine eye check-up or correction may be beneficial."
    }
    
    // Imbalance only
    if eyeDiff {
        return "Your vision is generally good but shows imbalance between eyes. A routine eye check-up is advised."
    }
    
    // Near vs distance mismatch
    if nearDistDiff {
        return "Your vision is fairly good but varies between near and distance. Minor correction may help improve clarity."
    }
    
    // Good
    if worstCategory == 1 {
        return "Your vision is fairly good overall. A routine eye check-up may help maintain clarity and eye health."
    }
    
    // Excellent
    return "Your vision is excellent overall. Maintain eye health with regular check-ups and good visual habits."
}
