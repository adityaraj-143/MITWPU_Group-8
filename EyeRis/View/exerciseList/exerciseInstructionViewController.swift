//
//  exerciseInstructionViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 23/01/26.
//

import UIKit
import AVKit

class exerciseInstructionViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var calibrateButton: UIButton!

    var exercise: Exercise?
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
        navigationController?.pushViewController(vc, animated: true)
    }
}
