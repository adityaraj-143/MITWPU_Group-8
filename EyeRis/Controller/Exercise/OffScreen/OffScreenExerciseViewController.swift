//
//  OffScreenViewViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 27/02/26.
//

import UIKit

class OffScreenExerciseViewController: UIViewController, ExerciseFlowHandling {
    var exercise: Exercise? = allExercises[1]
    
    var inTodaySet: Int?
    
    var referenceDistance: Int = 0
    
    private var stages: [ExerciseStage] = []
    private var currentStageIndex = 0
    private var countdownTimer: Timer?
    private var remainingTime = 0
    
    func navigate(to storyboard: String, id identifier: String, nextExercise: Exercise?) {
        
    }
    

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
        print("Exercise Completed")
    }
}
