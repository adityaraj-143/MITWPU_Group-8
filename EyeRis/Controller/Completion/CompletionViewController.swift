import UIKit
import AVFoundation

enum CompletionSource {
    case AcuityTest
    case BlinkRateTest
    case TodaysSet
    case ExerciseList
    case Recommended
}

final class CompletionViewController: UIViewController {
    
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var successImageView: UIImageView!
    @IBOutlet weak var TimeTakenLabel: UILabel!
    @IBOutlet weak var ActualTimeTaken: UILabel!
    @IBOutlet weak var completionLabel: UILabel!
    
    private var audioPlayer: AVAudioPlayer?
    var source: CompletionSource?
    
    var resultNav = ""
    var resultNavId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ALL RESULTS:")
        AcuityTestResultResponse.shared.results.forEach {
            print($0)
        }
    }
    
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
            
        case .TodaysSet, .ExerciseList, .Recommended:
            completionLabel.text = "Exercise Completed!"
            resultNav = "ExerciseHistory"
            resultNavId = "ExerciseHistoryViewController"
            
        case .none:
            assertionFailure("CompletionViewController.source was not set")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
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
    
    @IBAction func homeButtonTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
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
    @IBAction func ResultsButtonTapped(_ sender: Any) {
        print(resultNav, resultNavId)
        navigate(
            to: resultNav,
            with: resultNavId,
            resetStack: true
        )
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
    
    @IBAction func backButtonTapped(_ sender: Any) {
        switch source {
        case .Recommended, .AcuityTest, .BlinkRateTest:
            goToHome()
        case .ExerciseList:
            goToList()
        case .TodaysSet:
            gotoTodaysSet()
        case .none:
            assertionFailure("Source not defined in completion page")
        }
    }
    
    private func navigate(to: String, with: String, resetStack: Bool = false) {
        guard !to.isEmpty, !with.isEmpty else { return }
        
        let storyboard = UIStoryboard(name: to, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: with)
        
        guard let nav = navigationController else { return }
        
        if resetStack {
            // Home -> Results (Completion removed)
            nav.setViewControllers([nav.viewControllers.first!, vc], animated: true)
        } else {
            nav.pushViewController(vc, animated: true)
        }
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
