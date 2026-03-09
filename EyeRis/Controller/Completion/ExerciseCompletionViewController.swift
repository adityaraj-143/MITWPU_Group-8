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
    @IBOutlet weak var TimeTakenLabel: UILabel!
    @IBOutlet weak var ActualTimeTaken: UILabel!
    @IBOutlet weak var completionLabel: UILabel!

    private var audioPlayer: AVAudioPlayer?

    var source: CompletionSource?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        completionLabel.text = "Exercise Completed!"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        playSuccessSound()
        playSuccessHaptic()

        startPulse()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            self.burstParticles()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            self.animateBottomStats()
        }
    }

    // same animation code as test controller

    @IBAction func backButtonTapped(_ sender: Any) {

        switch source {

        case .Recommended:
            goToHome()

        case .ExerciseList:
            goToList()

        case .TodaysSet:
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

    private func animateBottomStats() {

        UIView.animate(
            withDuration: 0.45,
            delay: 0.6,
            options: [.curveEaseOut],
            animations: {

                self.TimeTakenLabel.alpha = 1
                self.ActualTimeTaken.alpha = 1
            }
        )
    }

    private func burstParticles() {

        let emitter = CAEmitterLayer()

        let center = view.convert(
            successImageView.center,
            from: successImageView.superview
        )

        emitter.emitterPosition = center

        let cell = CAEmitterCell()

        cell.birthRate = 22
        cell.lifetime = 1.8
        cell.velocity = 140
        cell.scale = 0.25
        cell.alphaSpeed = -0.12

        cell.contents = makeGreenDot(size: 20).cgImage

        emitter.emitterCells = [cell]

        view.layer.addSublayer(emitter)

        emitter.birthRate = 1

        DispatchQueue.main.async {
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