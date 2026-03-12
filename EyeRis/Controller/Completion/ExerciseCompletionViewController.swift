//
//  ExerciseCompletionViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 09/03/26.
//


import UIKit
import AVFoundation

final class ExerciseCompletionViewController: UIViewController {
    


    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var successImageView: UIImageView!


    @IBOutlet weak var completionLabel: UILabel!

    @IBOutlet weak var homeButton: UIButton!
    
    var source: ExerciseSource?
    var flowMode: ExerciseFlowMode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        switch flowMode {
        case .set:
            completionLabel.text = "Exercise Set Completed!"
           
        case .single:
            completionLabel.text = "Exercise Completed!"

        case .none:
            completionLabel.text = "Exercise Completed!"

        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        CompletionAnimations.playSuccessSound()
        CompletionAnimations.playSuccessHaptic()

        iconContainerView.layer.removeAllAnimations()
        iconContainerView.transform = .identity
        CompletionAnimations.startPulse(iconContainerView)

        view.layoutIfNeeded()

        DispatchQueue.main.async {
            CompletionAnimations.burstParticles(
                in: self.view,
                around: self.successImageView
            )
        }
    }
    // same animation code as test controller

    @IBAction func backButtonTapped(_ sender: Any) {

        switch source {

        case .recommended:
            goToHome()

        case .list:
            goToList()

        case .todaysSet:
            gotoTodaysSet()

        default:
            assertionFailure("Source not defined")
        }
    }
    
    @IBAction func homeButtonTapped(_ sender: Any) {
        goToHome()
    }
    
    @IBAction func exerciseButtonTapped(_ sender: Any) {
        goToList()
    }
    

    // navigation helpers

    private func goToHome() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    

    private func gotoTodaysSet() {

        let storyboard = UIStoryboard(
            name: "TodaysExerciseSet",
            bundle: nil
        )

        let vc = storyboard.instantiateViewController(
            withIdentifier: "TodaysExerciseSetViewController"
        )

        navigationController?.setViewControllers(
            [navigationController!.viewControllers.first!, vc],
            animated: true
        )
    }
    

    private func goToList() {

        let storyboard = UIStoryboard(
            name: "ExerciseList",
            bundle: nil
        )

        let vc = storyboard.instantiateViewController(
            withIdentifier: "ExerciseListViewController"
        )

        navigationController?.setViewControllers(
            [navigationController!.viewControllers.first!, vc],
            animated: true
        )
    }

    // animation helpers
    
    
    
    
 
}
