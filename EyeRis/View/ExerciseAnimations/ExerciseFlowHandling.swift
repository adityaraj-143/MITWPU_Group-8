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

        // Individual exercise → direct completion
        if inTodaySet == 0 {
            navigate(
                to: "Completion",
                id: "CompletionViewController",
                nextExercise: nil
            )
            return
        }

        // Set flow
        guard let list = ExerciseList.shared else { return }
        list.markCompleted(exercise: currentExercise)

        if let next = list.nextExercise(after: currentExercise) {
            // Instead of jumping to exercise → jump to instructions
            navigate(
                to: "exerciseInstruction",
                id: "ExerciseInstructionViewController",
                nextExercise: next
            )
        } else {
            // Set finished
            navigate(
                to: "Completion",
                id: "CompletionViewController",
                nextExercise: nil
            )
        }
    }
}
