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
    @IBOutlet weak var TimeTakenLabel: UILabel!
    @IBOutlet weak var ActualTimeTaken: UILabel!
    @IBOutlet weak var completionLabel: UILabel!

    private var audioPlayer: AVAudioPlayer?

    var source: ExerciseSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleButtons()
        completionLabel.text = "Exercise Completed!"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        playSuccessSound()
        playSuccessHaptic()
        startPulse()

 
            self.burstParticles()
        

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
    
    
    
    private func startPulse() {

        UIView.animate(
            withDuration: 1.6,
            delay: 0,
            options: [.autoreverse,.repeat,.curveEaseInOut],
            animations: {
                self.iconContainerView.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
            }
        )
    }

 

    private func burstParticles() {
        let emitter = CAEmitterLayer()
        emitter.zPosition = 1000

        let center = view.convert(successImageView.center, from: successImageView.superview)
        emitter.emitterPosition = center

        let radius = max(successImageView.bounds.width, successImageView.bounds.height) * 0.55
        emitter.emitterShape = .circle
        emitter.emitterMode = .outline
        emitter.emitterSize = CGSize(width: radius, height: radius)

        let cell = CAEmitterCell()
        cell.birthRate = 22
        cell.lifetime = 1.8
        cell.lifetimeRange = 0.3
        cell.emissionLongitude = 0
        cell.emissionRange = .pi / 12
        cell.velocity = 140
        cell.velocityRange = 30
        cell.scale = 0.25
        cell.scaleRange = 0.06
        cell.scaleSpeed = -0.02
        cell.alphaSpeed = -0.12
        cell.contents = makeGreenDot(size: 20).cgImage

        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)

        emitter.birthRate = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {  // ← fixed, not instant
            emitter.birthRate = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            emitter.removeFromSuperlayer()
        }
    }
    
    
 
    

    private func makeGreenDot(size: CGFloat) -> UIImage {

        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: size, height: size)
        )

        return renderer.image { ctx in

            UIColor(
                red: 0.22,
                green: 0.75,
                blue: 0.45,
                alpha: 1
            ).setFill()

            ctx.cgContext.fillEllipse(
                in: CGRect(x: 0, y: 0, width: size, height: size)
            )
        }
    }

    private func playSuccessSound() {

        guard let url = Bundle.main.url(
            forResource: "Success",
            withExtension: "mp3"
        ) else { return }

        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()
    }

    private func playSuccessHaptic() {

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
