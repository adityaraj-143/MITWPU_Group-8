//
//  TestCompletionViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 09/03/26.
//


import UIKit
import AVFoundation

final class TestCompletionViewController: UIViewController {

    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var successImageView: UIImageView!
    @IBOutlet weak var TimeTakenLabel: UILabel!
    @IBOutlet weak var ActualTimeTaken: UILabel!
    @IBOutlet weak var completionLabel: UILabel!

    private var audioPlayer: AVAudioPlayer?

    var source: CompletionSource?

    var resultNav = ""
    var resultNavId = ""

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch source {

        case .AcuityTest:
            completionLabel.text = "Acuity Test Completed!"
            resultNav = "TestHistory"
            resultNavId = "TestHistoryViewController"

        case .BlinkRateTest:
            completionLabel.text = "Blink Rate Test Completed!"
            resultNav = "BlinkRateHistory"
            resultNavId = "BlinkRateHistoryViewController"

        default:
            assertionFailure("Invalid source for TestCompletionViewController")
        }
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

    // MARK: Pulse

    private func startPulse() {
        UIView.animate(
            withDuration: 1.6,
            delay: 0,
            options: [.autoreverse,.repeat,.curveEaseInOut,.allowUserInteraction],
            animations: {
                self.iconContainerView.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
            }
        )
    }

    // MARK: Particles

    private func burstParticles() {

        let emitter = CAEmitterLayer()

        let center = view.convert(
            successImageView.center,
            from: successImageView.superview
        )

        emitter.emitterPosition = center

        let radius = max(
            successImageView.bounds.width,
            successImageView.bounds.height
        ) * 0.55

        emitter.emitterShape = .circle
        emitter.emitterMode = .outline
        emitter.emitterSize = CGSize(width: radius, height: radius)

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

    // MARK: Buttons

    @IBAction func homeButtonTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func resultsButtonTapped(_ sender: Any) {

        guard !resultNav.isEmpty else { return }

        let storyboard = UIStoryboard(name: resultNav, bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: resultNavId
        )

        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        goToHome()
    }

    // MARK: Navigation

    private func goToHome() {

        guard let nav = navigationController else { return }

        for vc in nav.viewControllers {
            if vc is ViewController {
                nav.popToViewController(vc, animated: true)
                return
            }
        }

        nav.popToRootViewController(animated: true)
    }

    private func animateBottomStats() {

        let groups: [[UIView]] = [
            [TimeTakenLabel, ActualTimeTaken],
        ]

        for (index, group) in groups.enumerated() {

            UIView.animate(
                withDuration: 0.45,
                delay: Double(index) * 0.68,
                options: [.curveEaseOut],
                animations: {

                    group.forEach {
                        $0.alpha = 1
                        $0.transform = .identity
                    }
                }
            )
        }
    }

    private func playSuccessSound() {

        guard let url = Bundle.main.url(
            forResource: "Success",
            withExtension: "mp3"
        ) else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.6
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

        } catch {
            print(error)
        }
    }

    private func playSuccessHaptic() {

        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}