//
//  ExerciseFlowHandling.swift
//  EyeRis
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

protocol ExerciseFlowHandling: AnyObject {
    var exercise: Exercise? { get set }
    var inTodaySet: Int? { get set }
    var referenceDistance: Int { get set }

    func navigate(to storyboard: String,
                  id identifier: String,
                  nextExercise: Exercise?)
}

extension ExerciseFlowHandling where Self: UIViewController {

    func handleExerciseCompletion() {
        print("Exercise finished – global flow handler")

        guard let currentExercise = exercise else { return }

        ExerciseList.shared?.markCompleted(exercise: currentExercise)

        if inTodaySet == 0 {
            navigate(
                to: "Completion",
                id: "CompletionViewController",
                nextExercise: nil
            )
            return
        }

        guard let list = ExerciseList.shared else { return }

        if let next = list.nextExercise(after: currentExercise) {
            navigate(
                to: "ExerciseInstruction",
                id: "ExerciseInstructionViewController",
                nextExercise: next
            )
        } else {
            navigate(
                to: "Completion",
                id: "CompletionViewController",
                nextExercise: nil
            )
        }
    }

}
