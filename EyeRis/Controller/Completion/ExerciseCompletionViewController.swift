//
//  ExerciseCompletionViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 09/03/26.
//


import UIKit
import AVFoundation

final class ExerciseCompletionViewController: UIViewController {
    
    @IBOutlet weak var resultsButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!

    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var successImageView: UIImageView!


    @IBOutlet weak var completionLabel: UILabel!


    var source: ExerciseSource?
    var flowMode: ExerciseFlowMode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleButtons()
        
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
        CompletionAnimations.startPulse(iconContainerView)

        CompletionAnimations.burstParticles(
            in: view,
            around: successImageView
        )
        

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

    // navigation helpers

    private func goToHome() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func resultsButtonTapped(_ sender: Any) {

        let storyboard = UIStoryboard(name: "ExerciseHistory", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "ExerciseHistoryViewController"
        )

        guard let nav = navigationController else { return }

        nav.setViewControllers([nav.viewControllers.first!, vc], animated: true)
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
    
    
    private func styleButtons() {
        
        // Primary
        // Results button (primary)
        resultsButton.backgroundColor = .systemBlue
        resultsButton.setTitleColor(.white, for: .normal)
        resultsButton.setTitleColor(.white, for: .highlighted)
        resultsButton.tintColor = .white
        resultsButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        resultsButton.layer.cornerRadius = 18
        resultsButton.clipsToBounds = true
        
        // Secondary
        homeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        homeButton.layer.cornerRadius = 18
        homeButton.clipsToBounds = true
        
        
        if traitCollection.userInterfaceStyle == .dark {
            resultsButton.backgroundColor = UIColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 1)
            homeButton.backgroundColor = UIColor(white: 0.22, alpha: 1)
            homeButton.setTitleColor(.systemGray2, for: .normal)
        } else {
            resultsButton.backgroundColor = UIColor(red: 0.1, green: 0.4, blue: 0.85, alpha: 1)
            homeButton.backgroundColor = UIColor(white: 0.96, alpha: 1)
            homeButton.setTitleColor(.systemGray3, for: .normal)
        }
    }
    
    
    
 
}
