//
//  ExerciseFlowHandling.swift
//  EyeRis
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

protocol ExerciseFlowHandling {
    var exercise: Exercise? { get set }
    var source: ExerciseSource? { get set }
    
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
            source: source
        )
    }
    
}

class ExerciseFlowCoordinator {
    
    static func handleCompletion(
        from vc: UIViewController,
        exercise: Exercise,
        source: ExerciseSource?
    ) {
        
        ExerciseList.shared?.markCompleted(exercise: exercise)
        
        switch source {
            
        case .todaysSet:
            
            guard let list = ExerciseList.shared else { return }
            
            if let next = list.nextExercise(after: exercise) {
                
                pushExercise(
                    from: vc,
                    exercise: next,
                    source: .todaysSet
                )
                
            } else {
                
                pushTestInstructions(from: vc)
                
            }
            
        case .recommended, .list:
            
            pushCompletion(from: vc, source: source)
            
        case .none:
            pushCompletion(from: vc, source: nil)
        }
    }
    
}


extension ExerciseFlowCoordinator {
    
    static func pushExercise(
        from vc: UIViewController,
        exercise: Exercise,
        source: ExerciseSource
    ) {

        let storyboardName = exercise.type == .onScreen
            ? "ExerciseInstruction"
            : "OffScreenExerciseInstruction"

        let identifier = exercise.type == .onScreen
            ? "ExerciseInstructionViewController"
            : "OffScreenExerciseInstructionViewController"

        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: identifier)

        if var instructionVC = nextVC as? ExerciseFlowHandling {
            instructionVC.exercise = exercise
            instructionVC.source = source
        }

        guard let nav = vc.navigationController else { return }
        nav.pushViewController(nextVC, animated: true)
    }
    
    static func pushTestInstructions(from vc: UIViewController) {
        
        let storyboard = UIStoryboard(name: "TestInstructions", bundle: nil)
        let nextVC = storyboard.instantiateViewController(
            withIdentifier: "TestInstructionsViewController"
        )
        
        if let testVC = nextVC as? TestInstructionsViewController {
            testVC.source = .todaysSet
        }
        
        vc.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    static func pushCompletion(
        from vc: UIViewController,
        source: ExerciseSource?
    ) {
        
        let storyboard = UIStoryboard(name: "Completion", bundle: nil)
        let nextVC = storyboard.instantiateViewController(
            withIdentifier: "CompletionViewController"
        )
        
        if let completionVC = nextVC as? CompletionViewController {
            
            switch source {
            case .todaysSet:
                completionVC.source = .TodaysSet
            case .recommended, .list:
                completionVC.source = .Recommended
            case .none:
                completionVC.source = .Recommended
            }
        }
        
        vc.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}
