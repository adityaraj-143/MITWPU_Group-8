import UIKit
import AVKit

class OffScreenExerciseInstructionViewController: UIViewController, ExerciseFlowHandling {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var calibrateButton: UIButton!
    
    var exercise: Exercise?
    var source: ExerciseSource?
    var flowMode: ExerciseFlowMode?
    var referenceDistance: Int = 40
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    // We’ll keep a reference to the observer so we can remove it in deinit
    private var playbackObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoContainerView.applyCornerRadius()
        videoContainerView.applyShadow()
        
        setupUI()
        setupVideo()
    }
    
    deinit {
        // Remove notification observer when this VC is deallocated
        if let playbackObserver {
            NotificationCenter.default.removeObserver(playbackObserver)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        switch source {
        case .todaysSet:
            gotoTodaysSet()
        case .recommended:
            goToHome()
        case .list:
            goToList()
        case .none:
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keep layer frame in sync with container view’s bounds
        playerLayer?.frame = videoContainerView.bounds
    }
    
    // MARK: - Setup
    
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
        // Avoid re‑creating the player if already set up
        guard player == nil else { return }
        
        // Get video URL from bundle
        guard
            let videoName = exercise?.instructions.video,
            let url = Bundle.main.url(forResource: videoName, withExtension: "mp4")
        else {
            assertionFailure("Missing video for exercise \(exercise?.name ?? "unknown")")
            return
        }
        
        // Create AVPlayer
        let player = AVPlayer(url: url)
        self.player = player
        
        // Create and attach AVPlayerLayer to container view
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        videoContainerView.layer.addSublayer(layer)
        self.playerLayer = layer
        
        // --- LOOPING LOGIC STARTS HERE ---
        
        // Observe when the current item finishes playing
        if let item = player.currentItem {
            playbackObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak self] _ in
                // When video ends, seek back to the start and play again
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }
        }
        
        // Start playback
        player.play()
    }
    
    @IBAction func buttonToNavigate(_ sender: Any) {
        guard let exercise else { return }
        
        let storyboard = UIStoryboard(
            name: "OffScreenExercise",
            bundle: nil
        )
        
        let vc = storyboard.instantiateViewController(
            withIdentifier: "OffScreenExerciseViewController"
        )
        
        if var exerciseVC = vc as? ExerciseFlowHandling {
            exerciseVC.exercise = exercise
            exerciseVC.source = source
            exerciseVC.flowMode = flowMode
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func gotoTodaysSet() {
        guard let nav = navigationController else { return }
        
        for vc in nav.viewControllers {
            if vc is TodaysExerciseSetViewController {
                nav.popToViewController(vc, animated: true)
                return
            }
        }
        
        let storyboard = UIStoryboard(name: "TodaysExerciseSet", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "TodaysExerciseSetViewController"
        )
        nav.setViewControllers([nav.viewControllers.first!, vc], animated: true)
    }
    
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
    
    private func goToList () {
        guard let nav = navigationController else { return }
        
        for vc in nav.viewControllers {
            if vc is ExerciseListViewController {
                nav.popToViewController(vc, animated: true)
                return
            }
        }
        
        let storyboard = UIStoryboard(name: "ExerciseList", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "ExerciseListViewController"
        )
        nav.setViewControllers([nav.viewControllers.first!, vc], animated: true)
    }
}
