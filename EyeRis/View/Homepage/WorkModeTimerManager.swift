//
//  WorkModeTimer.swift
//  EyeRis
//
//  Created by SDC-USER on 12/02/26.
//

import Foundation

final class WorkModeTimerManager {

    static let shared = WorkModeTimerManager()
    private init() {}

    var endTime: Date?
    var initialDuration: Int = 0
    var isRunning: Bool = false
    var isBreak: Bool = false
}

