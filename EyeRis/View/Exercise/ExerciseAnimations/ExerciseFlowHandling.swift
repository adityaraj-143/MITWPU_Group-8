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

class ExerciseFlowCoordinator {
    
    static func handleCompletion(
        from vc: UIViewController,
        exercise: Exercise,
        source: ExerciseSource?,
        flowMode: ExerciseFlowMode?
    ) {
        
        ExerciseList.shared?.markCompleted(exercise: exercise)
        
        switch source {
            
        case .todaysSet:

            if flowMode == .single {
                pushCompletion(from: vc, source: .todaysSet)
                return
            }

            guard let list = ExerciseList.shared else { return }

            if let next = list.nextExercise(after: exercise) {

                pushExercise(
                    from: vc,
                    exercise: next,
                    source: .todaysSet,
                    flowMode: .set
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
        source: ExerciseSource,
        flowMode: ExerciseFlowMode
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
            instructionVC.flowMode = flowMode
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
            testVC.flowMode = .set
        }
        
        vc.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    static func pushCompletion(
        from vc: UIViewController,
        source: ExerciseSource?
    ) {
        
        let storyboard = UIStoryboard(name: "ExerciseCompletion", bundle: nil)
        let nextVC = storyboard.instantiateViewController(
            withIdentifier: "ExerciseCompletionViewController"
        )
        
        if let completionVC = nextVC as? ExerciseCompletionViewController {
            
            switch source {
            case .todaysSet:
                completionVC.source = .todaysSet
            case .recommended:
                completionVC.source = .recommended
            case .list:
                completionVC.source = .list
            case .none:
                completionVC.source = .recommended
            }
        }
        
        vc.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}
