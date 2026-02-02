//
//  exerciseInstructionViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 23/01/26.
//

import UIKit
import AVKit

enum ExerciseEntrySource {
    case todaySet
    case home
    case list
}

class ExerciseInstructionViewController: UIViewController, ExerciseFlowHandling {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var calibrateButton: UIButton!
    
    var exercise: Exercise?
    var inTodaySet: Int? = 0
    var referenceDistance: Int = 40
    var source: ExerciseEntrySource?
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoContainerView.applyCornerRadius()
        videoContainerView.applyShadow()
        
        setupUI()
        setupVideo()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        switch source {
            
        case .todaySet:
            gotoTodaysSet()
            
        case .home:
            navigationController?.popViewController(animated: true)
            
        case .list:
            goToList()
        case .none:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }
    
    //MARK: SETUP
    private func setupUI() {
        guard let exercise = exercise else {
            assertionFailure("ExerciseInstructionVC opened without Exercise")
            return
        }
        
        navigationItem.title = exercise.name
        descriptionLabel.text = exercise.instructions.description
        print("Exercise passed:", exercise as Any)
    }
    
    private func setupVideo() {
        guard player == nil else { return }
        guard
            let videoName = exercise?.instructions.video,
            let url = Bundle.main.url(
                forResource: videoName,
                withExtension: "mp4"
            )
        else {
            assertionFailure("Missing video for exercise \(exercise?.name ?? "unknown")")
            return
        }

        let player = AVPlayer(url: url)
        self.player = player

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        videoContainerView.layer.addSublayer(layer)
        self.playerLayer = layer

        player.play()
    }
    
    @IBAction func calibrateTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "ExerciseCalibration", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "ExerciseCalibrationViewController"
        ) as! ExerciseCalibrationViewController
        
        vc.exercise = exercise
        vc.inTodaySet = inTodaySet
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigate(to storyboard: String,
                  id identifier: String,
                  nextExercise: Exercise?) {
        
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
        if let nextExercise,
           let exerciseVC = vc as? ExerciseFlowHandling {
            exerciseVC.exercise = nextExercise
            exerciseVC.inTodaySet = inTodaySet
            exerciseVC.referenceDistance = referenceDistance
        }
        
        if let completionVC = vc as? CompletionViewController {
            completionVC.source = .Exercise
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func gotoTodaysSet() {
        guard let nav = navigationController else { return }
        
        for vc in nav.viewControllers {
            if vc is TodaysExerciseSetViewController {
                nav.popToViewController(vc, animated: true)
                return
            }
        }
        
        // Fallback if for some reason it’s not in stack
        let storyboard = UIStoryboard(name: "TodaysExerciseSet", bundle: nil) // use your real storyboard name
        let vc = storyboard.instantiateViewController(
            withIdentifier: "TodaysExerciseSetViewController"
        )
        nav.setViewControllers([nav.viewControllers.first!, vc], animated: true)
    }
    
    private func goToHome() {
        guard let nav = navigationController else { return }
        
        // Find your home screen in stack
        for vc in nav.viewControllers {
            if vc is ViewController {   // change to your real home VC class
                nav.popToViewController(vc, animated: true)
                return
            }
        }
        
        // Fallback
        nav.popToRootViewController(animated: true)
    }
    
    private func goToList () {
        guard let nav = navigationController else { return }
        
        for vc in nav.viewControllers {
            if vc is ExerciseListViewController {
                nav.popToViewController(vc, animated: true)
                return
            }
        }
        
        // Fallback if for some reason it’s not in stack
        let storyboard = UIStoryboard(name: "ExerciseList", bundle: nil) // use your real storyboard name
        let vc = storyboard.instantiateViewController(
            withIdentifier: "ExerciseListViewController"
        )
        nav.setViewControllers([nav.viewControllers.first!, vc], animated: true)
    }
}
