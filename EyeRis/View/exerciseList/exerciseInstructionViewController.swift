//
//  exerciseInstructionViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 23/01/26.
//

import UIKit
import AVKit

class exerciseInstructionViewController: UIViewController, ExerciseFlowHandling {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var calibrateButton: UIButton!
    
    var exercise: Exercise?
    var inTodaySet: Int? = 0
    var referenceDistance: Int = 40   // default

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupVideo()
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
        let fileName = exercise?.instructions.video.replacingOccurrences(of: ".mp4", with: "")
        
        guard let path = Bundle.main.path(forResource: fileName, ofType: "mp4") else {
            print("Video not found")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoContainerView.bounds
        playerLayer?.videoGravity = .resizeAspect
        
        if let playerLayer = playerLayer {
            videoContainerView.layer.addSublayer(playerLayer)
        }
        
        player?.play()
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

}
