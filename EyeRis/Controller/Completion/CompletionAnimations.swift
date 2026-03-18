import UIKit
import AVFoundation

final class CompletionAnimations {

    private static var audioPlayer: AVAudioPlayer?

    // MARK: Pulse

    static func startPulse(_ view: UIView) {

        UIView.animate(
            withDuration: 1.6,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: {
                view.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
            }
        )
    }

    // MARK: Bottom Labels

    static func animateStats(_ views: [UIView]) {

        for (index, view) in views.enumerated() {

            UIView.animate(
                withDuration: 0.45,
                delay: Double(index) * 0.68,
                options: [.curveEaseOut],
                animations: {

                    view.alpha = 1
                    view.transform = .identity
                }
            )
        }
    }

    // MARK: Particles

    static func burstParticles(
        in rootView: UIView,
        around imageView: UIImageView
    ) {

        rootView.layoutIfNeeded()

        // Remove old emitters (prevents stacking bugs)
        rootView.layer.sublayers?
            .filter { $0 is CAEmitterLayer }
            .forEach { $0.removeFromSuperlayer() }

        let emitter = CAEmitterLayer()

        let center = rootView.convert(
            imageView.center,
            from: imageView.superview
        )

        emitter.emitterPosition = center
        emitter.zPosition = 1000

        // Use a sensible fallback if imageView hasn't laid out yet
        let imageSize = imageView.bounds.size
        let radius = max(imageSize.width, imageSize.height) > 0
            ? max(imageSize.width, imageSize.height) * 0.55
            : 40.0

        emitter.emitterShape = .circle
        emitter.emitterMode = .outline
        emitter.emitterSize = CGSize(width: radius, height: radius)

        let cell = CAEmitterCell()

        cell.birthRate = 22
        cell.lifetime = 1.8
        cell.velocity = 140
        cell.velocityRange = 30

        cell.scale = 0.25
        cell.scaleRange = 0.06

        cell.alphaSpeed = -0.12

        cell.contents = makeGreenDot(size: 20).cgImage

        emitter.emitterCells = [cell]

        rootView.layer.addSublayer(emitter)

        emitter.birthRate = 1

        // async{} is too fast — Core Animation hasn't rendered a single frame yet
        // so particles get killed before they're ever visible. Use a real delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            emitter.birthRate = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            emitter.removeFromSuperlayer()
        }
    }
    
    
    // MARK: Particle Image

    private static func makeGreenDot(size: CGFloat) -> UIImage {

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

    // MARK: Sound

    static func playSuccessSound() {

        guard let url = Bundle.main.url(
            forResource: "Success",
            withExtension: "mp3"
        ) else { return }

        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.volume = 0.6
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }

    // MARK: Haptic

    static func playSuccessHaptic() {

        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}
