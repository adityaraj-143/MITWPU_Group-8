//
//  ExerciseAlignmentMonitor.swift
//  EyeRis
//
//  Created by SDC-USER on 23/01/26.
//

import Foundation
import UIKit

protocol ExerciseAlignmentMonitoring: AnyObject {
    func showPause(reason: CameraAlignmentState)
}

extension ExerciseAlignmentMonitoring where Self: UIViewController {

    func startAlignmentMonitoring(
        timer: inout Timer?
    ) {
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            let state = CameraManager.shared.alignmentState
            if state != .manual {
                self.showPause(reason: state)
            }
        }
    }

    func stopAlignmentMonitoring(timer: inout Timer?) {
        timer?.invalidate()
        timer = nil
    }
}
