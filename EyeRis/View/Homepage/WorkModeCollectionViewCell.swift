import UIKit

class WorkModeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var modeToggle: UISwitch!
    @IBOutlet weak var notificationsSent: UILabel!
    
    private var orb: UIView!
    private var trail: CAShapeLayer!
    private var lastCardFrame: CGRect = .zero

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupOrbAndTrail()
        setupObservers()
    }

    // MARK: - Setup

    private func setupUI() {
        mainView.clipsToBounds = false
        mainView.layer.masksToBounds = false
        contentView.clipsToBounds = false
        clipsToBounds = false

        mainView.applyCornerRadius()
        iconView.makeRounded()

        modeToggle.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        modeToggle.isOn = WorkModeTimerManager.shared.isRunning
        
        notificationsSent.text = "Breaks until now: \(WorkModeTimerManager.shared.notificationsSent)"
    }

    private func setupOrbAndTrail() {
        orb = OrbAnimations.createOrb(in: contentView)
        trail = OrbAnimations.createTrail(in: contentView)
    }

    private func setupObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(onStateChanged(_:)), name: .workModeStateChanged, object: nil)
        nc.addObserver(self, selector: #selector(onBreakStarted), name: .workModeBreakStarted, object: nil)
        nc.addObserver(self, selector: #selector(onWorkResumed), name: .workModeWorkResumed, object: nil)
        nc.addObserver(self, selector: #selector(onNotificationSent(_:)), name: .workModeNotificationSent, object: nil)
    }

    // MARK: - Layout Changes (Rotation / Different Device)

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Only act if card frame actually changed
        guard mainView.frame != lastCardFrame else { return }
        lastCardFrame = mainView.frame
        
        // If animation is running, restart with new path at current progress
        if WorkModeTimerManager.shared.isRunning {
            resumeAnimation()
        }
    }

    // MARK: - Animation Control

    private func currentPhase() -> OrbPhase {
        WorkModeTimerManager.shared.isBreak ? .rest : .work
    }

    private func currentDuration() -> TimeInterval {
        if WorkModeTimerManager.shared.isBreak {
            return 20
        } else {
            let storedMinutes = UserDefaults.standard.integer(forKey: "workModeMinutes")
            let minutes = storedMinutes > 0 ? storedMinutes : WorkModeTimerManager.defaultWorkMinutes
            return TimeInterval(minutes * 60)
        }
    }

    private func startAnimation(phase: OrbPhase, duration: TimeInterval) {
        OrbAnimations.start(
            orb: orb,
            trail: trail,
            around: mainView,
            duration: duration,
            phase: phase
        )
    }

    private func resumeAnimation() {
        let phase = currentPhase()
        let duration = currentDuration()
        let progress = WorkModeTimerManager.shared.progress()
        
        OrbAnimations.resume(
            orb: orb,
            trail: trail,
            around: mainView,
            duration: duration,
            phase: phase,
            progress: progress
        )
    }

    private func stopAnimation() {
        OrbAnimations.stop(orb: orb, trail: trail)
    }

    // MARK: - Toggle Action

    @IBAction func modeToggleChanged(_ sender: UISwitch) {
        if sender.isOn {
            let duration = currentDuration()
            startAnimation(phase: .work, duration: duration)
            OrbAnimations.showWorkModeEnabledToast(in: contentView)
            WorkModeTimerManager.shared.start()
        } else {
            WorkModeTimerManager.shared.stop()
            stopAnimation()
            notificationsSent.text = "Breaks until now: 0"
        }
    }

    // MARK: - Notification Handlers

    @objc private func onStateChanged(_ notification: Notification) {
        guard let isRunning = notification.object as? Bool else { return }
        
        if isRunning {
            let duration = currentDuration()
            startAnimation(phase: .work, duration: duration)
            modeToggle.setOn(true, animated: true)
        } else {
            stopAnimation()
        }
    }

    @objc private func onBreakStarted() {
        // Smoothly transition to orange break animation
        OrbAnimations.transition(
            orb: orb,
            trail: trail,
            around: mainView,
            duration: 20,
            toPhase: .rest
        )
    }
    
    @objc private func onWorkResumed() {
        // Smoothly transition back to green work animation
        let duration = currentDuration()
        OrbAnimations.transition(
            orb: orb,
            trail: trail,
            around: mainView,
            duration: duration,
            toPhase: .work
        )
    }

    @objc private func onNotificationSent(_ notification: Notification) {
        guard let count = notification.object as? Int else { return }
        notificationsSent.text = "Breaks until now: \(count)"
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        modeToggle.isOn = WorkModeTimerManager.shared.isRunning
        
        if WorkModeTimerManager.shared.isRunning {
            resumeAnimation()
        } else {
            stopAnimation()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
