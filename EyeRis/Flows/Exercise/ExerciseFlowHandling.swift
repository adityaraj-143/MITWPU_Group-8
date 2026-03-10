//
//  ExerciseFlowHandling.swift
//  EyeRis
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

enum ExerciseFlowMode {
    case single
    case set
}

protocol ExerciseFlowHandling {
    var exercise: Exercise? { get set }
    var source: ExerciseSource? { get set }
    var flowMode: ExerciseFlowMode? { get set }
    
    func exerciseCompleted()
}

protocol OnScreenExerciseFlow: ExerciseFlowHandling {
    var referenceDistance: Int { get set }
}

extension ExerciseFlowHandling where Self: UIViewController {
    
    func exerciseCompleted() {
        guard let exercise else { return }
        
        ExerciseFlowCoordinator.handleCompletion(
            from: self,
            exercise: exercise,
            source: source,
            flowMode: flowMode
        )
    }
    
}


