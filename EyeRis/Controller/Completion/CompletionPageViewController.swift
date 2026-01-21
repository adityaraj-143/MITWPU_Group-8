import UIKit

final class CompletionPageViewController: UIViewController {

    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var successImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initial state
        iconContainerView.alpha = 0
        iconContainerView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)

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
            withDuration: 0.9,
            delay: 0.05,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.4,
            options: [.curveEaseOut],
            animations: {
                self.iconContainerView.alpha = 1
                self.iconContainerView.transform = .identity
            }
        )

        // Fire particles while icon is settling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.burstParticles()
        }

        // Start pulse AFTER particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.startPulse()
        }
    }

    // MARK: - Pulse

    private func startPulse() {
        UIView.animate(
            withDuration: 1.6,
            delay: 0,
            options: [.autoreverse, .repeat, .allowUserInteraction],
            animations: {
                self.iconContainerView.transform =
                    CGAffineTransform(scaleX: 1.04, y: 1.04)
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
}
