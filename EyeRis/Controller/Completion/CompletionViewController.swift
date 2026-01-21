import UIKit
import AVFoundation

final class CompletionViewController: UIViewController {
    
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var successImageView: UIImageView!
    @IBOutlet weak var TimeTakenLabel: UILabel!
    @IBOutlet weak var ActualTimeTaken: UILabel!
    
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.layoutIfNeeded()
        
        playSuccessSound()
        playSuccessHaptic()
        
//        popAndPulse()
        startPulse()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            self.burstParticles()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            self.animateBottomStats()
        }
    }
    
    // MARK: - Pulse
    
    private func startPulse() {
        UIView.animate(
            withDuration: 1.6,
            delay: 0,
            options: [
                .autoreverse,
                .repeat,
                .curveEaseInOut,
                .allowUserInteraction
            ],
            animations: {
                self.iconContainerView.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
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
    
    private func popAndPulse() {
        iconContainerView.alpha = 1
        iconContainerView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        UIView.animateKeyframes(
            withDuration: 0.55,
            delay: 0,
            options: [.calculationModeCubic, .allowUserInteraction],
            animations: {

                // Pop
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.45) {
                    self.iconContainerView.transform = CGAffineTransform(scaleX: 1.18, y: 1.18)
                }

                // Soft settle
                UIView.addKeyframe(withRelativeStartTime: 0.50, relativeDuration: 0.25) {
                    self.iconContainerView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                }
            },
            completion: { _ in
                self.startPulse()
            }
        )

        // Particles hit at peak energy
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            self.burstParticles()
        }
    }

}
