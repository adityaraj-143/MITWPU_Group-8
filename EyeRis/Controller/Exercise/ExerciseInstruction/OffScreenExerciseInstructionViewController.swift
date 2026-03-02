//
//  OffScreenExerciseInstructionViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 02/03/26.
//

import UIKit

class OffScreenExerciseInstructionViewController: UIViewController, ExerciseFlowHandling {
    var exercise: Exercise?
    
    var inTodaySet: Int?
    
    var referenceDistance: Int = 0
    
    func navigate(to storyboard: String, id identifier: String, nextExercise: Exercise?) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
        if let nextExercise,
           let exerciseVC = vc as? ExerciseFlowHandling {
            exerciseVC.exercise = nextExercise
            exerciseVC.inTodaySet = inTodaySet
            exerciseVC.referenceDistance = referenceDistance
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    var source: ExerciseEntrySource?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonToNavigate(_ sender: Any) {
        navigate(to: "OffScreenExercise", id: "OffScreenExerciseViewController", nextExercise: exercise)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
