//
//  OffScreenViewViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 27/02/26.
//

enum ExerciseSource {
    case todaysSet
    case recommended
    case list
}

import UIKit

class OffScreenExerciseViewController: UIViewController, ExerciseFlowHandling {
    
    var exercise: Exercise?
    var source: ExerciseSource?
    
    private var stages: [ExerciseStage] = []
    private var currentStageIndex = 0
    private var countdownTimer: Timer?
    private var remainingTime = 0
    

    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stages = exercise?.getPerformanceInstruction() ?? []
        startNextStage()
    }

    private func startNextStage() {
        // Stop if finished
        if currentStageIndex >= stages.count {
            finishExercise()
            return
        }

        let stage = stages[currentStageIndex]

        instructionLabel.text = stage.instruction
        remainingTime = stage.duration
        timerLabel.text = "\(remainingTime)"

        startTimer()
    }
    
    private func startTimer() {
        countdownTimer?.invalidate()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            self.remainingTime -= 1
            self.timerLabel.text = "\(self.remainingTime)"

            if self.remainingTime <= 0 {
                timer.invalidate()
                self.currentStageIndex += 1
                self.startNextStage()
            }
        }
    }
    
    private func finishExercise() {
        exerciseCompleted()
    }
}
