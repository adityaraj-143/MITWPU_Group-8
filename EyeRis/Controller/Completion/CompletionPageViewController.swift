import UIKit
import AVFoundation

final class CompletionPageViewController: UIViewController {

    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var successImageView: UIImageView!
    @IBOutlet weak var TimeTakenLabel: UILabel!
    @IBOutlet weak var ActualTimeTaken: UILabel!
    @IBOutlet weak var StatLabel1: UILabel!
    @IBOutlet weak var StatLabel2: UILabel!
    
    private var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initial state
        iconContainerView.alpha = 0
        iconContainerView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        
        let bottomViews = [TimeTakenLabel, StatLabel1, StatLabel2, ActualTimeTaken]

        bottomViews.forEach {
            $0?.alpha = 0
            $0?.transform = CGAffineTransform(translationX: 0, y: 12)
        }


        // Required so particles can escape
        iconContainerView.clipsToBounds = false
        successImageView.clipsToBounds = false
        successImageView.layer.masksToBounds = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.layoutIfNeeded()

        // Entrance animation
        UIView.animate(
            withDuration: 0.6,
            delay: 0.05,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut],
            animations: {
                self.iconContainerView.alpha = 1
                self.iconContainerView.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    options: [.curveEaseOut],
                    animations: {
                        self.iconContainerView.transform = .identity
                    }
                )
            }
        )


        // Fire particles while icon is settling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.40) {
            self.burstParticles()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            self.playSuccessSound()
            self.playSuccessHaptic()

        }

        // Start pulse AFTER particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.startPulse()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            self.animateBottomStats()
        }

    }

    // MARK: - Pulse

    private func startPulse() {
        UIView.animate(
            withDuration: 1.25,
            delay: 0,
            options: [
                .autoreverse,
                .repeat,
                .allowUserInteraction,
                .curveEaseInOut
            ],
            animations: {
                self.iconContainerView.transform =
                    CGAffineTransform(scaleX: 1.12, y: 1.12)
            }
        )
    }


    // MARK: - Particles (TRUE ONE-SHOT, STABLE)

    private func burstParticles() {
        let emitter = CAEmitterLayer()
        emitter.zPosition = 1000

        // Position in root view space
        let center = view.convert(
            successImageView.center,
            from: successImageView.superview
        )
        emitter.emitterPosition = center

        // Emit slightly outside icon
        let radius = max(
            successImageView.bounds.width,
            successImageView.bounds.height
        ) * 0.55

        emitter.emitterShape = .circle
        emitter.emitterMode = .outline
        emitter.emitterSize = CGSize(width: radius, height: radius)

        let cell = CAEmitterCell()

        // Particle spawn & life
        cell.birthRate = 22
        cell.lifetime = 1.8
        cell.lifetimeRange = 0.3

        // Outward-only emission
        cell.emissionLongitude = 0
        cell.emissionRange = .pi / 12

        cell.velocity = 140
        cell.velocityRange = 30

        // Size & fade (controls how long they FEEL alive)
        cell.scale = 0.25
        cell.scaleRange = 0.06
        cell.scaleSpeed = -0.02
        cell.alphaSpeed = -0.12

        // Solid green particle (no tint bugs)
        cell.contents = makeGreenDot(size: 20).cgImage

        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)

        // 🔥 TRUE one-shot burst (UIKit-safe)
        emitter.birthRate = 1
        DispatchQueue.main.async {
            emitter.birthRate = 0
        }

        // Cleanup after particles naturally die
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            emitter.removeFromSuperlayer()
        }
    }

    // MARK: - Green Particle Image

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
    
    
    private func animateBottomStats() {

        // Group views that should animate together
        let groups: [[UIView]] = [
            [TimeTakenLabel, ActualTimeTaken], // animate together
            [StatLabel1],                      // next
            [StatLabel2]                       // last
        ]

        for (index, group) in groups.enumerated() {
            UIView.animate(
                withDuration: 0.45,
                delay: Double(index) * 0.68,
                options: [.curveEaseOut],
                animations: {
                    group.forEach { view in
                        view.alpha = 1
                        view.transform = .identity
                    }
                }
            )
        }
    }

    
    private func playSuccessSound() {
        guard let url = Bundle.main.url(forResource: "Success", withExtension: "mp3") else {
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.6
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play sound:", error)
        }
    }
    
    private func playSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }



}
