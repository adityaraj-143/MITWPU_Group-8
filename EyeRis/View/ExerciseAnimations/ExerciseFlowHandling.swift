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
    
    func navigate(to storyboard: String,
                  id identifier: String,
                  nextExercise: Exercise?)
}

extension ExerciseFlowHandling where Self: UIViewController {

    func handleExerciseCompletion() {
        print("Exercise finished – global flow handler")

        guard let currentExercise = exercise else { return }

        // Case 1: Came individually → go directly to completion
        if inTodaySet == 0 {
            navigate(
                to: "Completion",
                id: "CompletionViewController",
                nextExercise: nil
            )
            return
        }

        // Case 2: Came from Today's Set → follow sequence
        guard let list = ExerciseList.shared else { return }

        list.markCompleted(exercise: currentExercise)

        if let next = list.nextExercise(after: currentExercise) {
            print("Next exercise:", next)

            navigate(
                to: next.getStoryboardName(),
                id: next.getStoryboardID(),
                nextExercise: next
            )
        } else {
            print("Today's set finished → completion")

            navigate(
                to: "Completion",
                id: "CompletionViewController",
                nextExercise: nil
            )
        }
    }
}
