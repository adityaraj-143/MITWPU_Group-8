//
//  OffScreenExerciseInstructionViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 02/03/26.
//

import UIKit

class OffScreenExerciseInstructionViewController: UIViewController, ExerciseFlowHandling {
    
    var exercise: Exercise?
    var source: ExerciseSource?
    var referenceDistance: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonToNavigate(_ sender: Any) {
        guard let exercise else { return }
        
        let storyboard = UIStoryboard(
            name: "OffScreenExercise",
            bundle: nil
        )
        
        let vc = storyboard.instantiateViewController(
            withIdentifier: "OffScreenExerciseViewController"
        )
        
        if var exerciseVC = vc as? ExerciseFlowHandling {
            exerciseVC.exercise = exercise
            exerciseVC.source = source
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}


