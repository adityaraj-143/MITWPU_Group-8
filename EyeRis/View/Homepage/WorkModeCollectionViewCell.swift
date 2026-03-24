import UIKit

class WorkModeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var modeToggle: UISwitch!
    @IBOutlet weak var notificationsSent: UILabel!
    
    private var orb: UIView?
    private var trail: CAShapeLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        notificationsSent.text = "Breaks until now: \(WorkModeTimerManager.shared.notificationsSent)"
        configureOrb()
        trail = OrbAnimations.attachTrail(to: contentView, around: mainView)
        configureObservers()
        syncAnimationsIfRunning()
    }

    // MARK: - Setup

    private func configureUI() {
        mainView.clipsToBounds = false
        mainView.layer.masksToBounds = false
        contentView.clipsToBounds = false
        clipsToBounds = false

        mainView.applyCornerRadius()
        iconView.makeRounded()

        modeToggle.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        modeToggle.isOn = WorkModeTimerManager.shared.isRunning
    }

    private func configureOrb() {
        orb = OrbAnimations.attachOrb(to: contentView)
        orb?.isHidden = !WorkModeTimerManager.shared.isRunning
    }

    private func configureObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange(_:)),
            name: .workModeStateChanged,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationSent(_:)),
            name: .workModeNotificationSent,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBreakStarted),
            name: .workModeBreakStarted,
            object: nil
        )
    }

    // MARK: - Sync

    /// Picks up wherever the global timer is — called on awake and reuse
    private func syncAnimationsIfRunning() {
        guard WorkModeTimerManager.shared.isRunning,
              let orb,
              let trail else { return }

        let phase: OrbPhase = WorkModeTimerManager.shared.isBreak ? .rest : .work
        let duration = currentPhaseDuration(for: phase)
        let progress = WorkModeTimerManager.shared.progress()

        OrbAnimations.resumeAnimations(
            orb: orb,
            trail: trail,
            around: mainView,
            duration: duration,
            phase: phase,
            progress: progress
        )
    }

    // MARK: - Helpers

    private func workDuration() -> TimeInterval {
        let minutes = UserDefaults.standard.integer(forKey: "workModeMinutes")
        return TimeInterval(minutes * 60)
    }

    private func currentPhaseDuration(for phase: OrbPhase) -> TimeInterval {
        phase == .work ? workDuration() : 20
    }

    // MARK: - Switch Action

    @IBAction func modeToggleChanged(_ sender: UISwitch) {
        guard let orb, let trail else { return }
        
        if sender.isOn {
            OrbAnimations.startAnimations(
                orb: orb,
                trail: trail,
                around: mainView,
                duration: workDuration(),
                phase: .work
            )
            OrbAnimations.showWorkModeEnabledToast(in: contentView, around: mainView)
            WorkModeTimerManager.shared.start()
        } else {
            WorkModeTimerManager.shared.stop()
            OrbAnimations.stopAnimations(orb: orb, trail: trail, around: mainView)
            notificationsSent.text = "Breaks until now: 0"
        }
    }

    // MARK: - Notifications
    
    @objc private func handleNotificationSent(_ notification: Notification) {
        guard let count = notification.object as? Int else { return }
        notificationsSent.text = "Breaks until now: \(count)"
    }
    
    @objc private func handleBreakStarted() {
        guard let orb, let trail else { return }

        // Start fresh 20-second break animation
        OrbAnimations.startAnimations(
            orb: orb,
            trail: trail,
            around: mainView,
            duration: 20,
            phase: .rest
        )
    }
    
    @objc private func handleStateChange(_ notification: Notification) {
        guard let isRunning = notification.object as? Bool else { return }
        orb?.isHidden = !isRunning

        if isRunning {
            guard let orb, let trail else { return }

            // Start fresh work phase animation
            OrbAnimations.startAnimations(
                orb: orb,
                trail: trail,
                around: mainView,
                duration: workDuration(),
                phase: .work
            )
            modeToggle.setOn(true, animated: true)
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        modeToggle.isOn = WorkModeTimerManager.shared.isRunning
        orb?.isHidden = !WorkModeTimerManager.shared.isRunning
        syncAnimationsIfRunning()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
