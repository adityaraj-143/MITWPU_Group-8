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
            selector: #selector(handleTick(_:)),
            name: .workModeTick,
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
        guard WorkModeTimerManager.shared.isRunning, let orb else { return }

        let minutes = UserDefaults.standard.integer(forKey: "workModeMinutes")
        let duration = TimeInterval(minutes * 60)
        let progress = WorkModeTimerManager.shared.progress()

        OrbAnimations.resumeOrbAnimation(orb, around: mainView, duration: duration, progress: progress)
        trail.flatMap { OrbAnimations.resumeTrailAnimation($0, duration: duration, progress: progress) }
    }

    // MARK: - Switch Action

    @IBAction func modeToggleChanged(_ sender: UISwitch) {
        guard let orb else { return }
        
        if sender.isOn {
            let minutes = UserDefaults.standard.integer(forKey: "workModeMinutes")
            let duration = TimeInterval(minutes * 60)
            
            OrbAnimations.resetOrb(orb, around: mainView)
            OrbAnimations.startOrbAnimation(orb, around: mainView, duration: duration)
            trail.flatMap { OrbAnimations.startTrailAnimation($0, duration: duration) }
            
            OrbAnimations.showWorkModeEnabledToast(in: contentView, around: mainView)
            WorkModeTimerManager.shared.start()
            
        } else {
            WorkModeTimerManager.shared.stop()
            OrbAnimations.stopOrbAnimation(orb)
            OrbAnimations.resetOrb(orb, around: mainView)
            trail.flatMap { OrbAnimations.stopTrailAnimation($0) }
            trail?.isHidden = true  // Also hide on manual stop
            notificationsSent.text = "Breaks until now: 0"
        }
    }

    // MARK: - Notifications
    
    @objc private func handleNotificationSent(_ notification: Notification) {

        guard let count = notification.object as? Int else { return }

        notificationsSent.text = "Breaks until now: \(count)"
    }
    
    @objc private func handleBreakStarted() {
        guard let orb else { return }

        // Recolor orb to orange for break
        orb.backgroundColor = .systemOrange
        orb.layer.shadowColor = UIColor.systemOrange.cgColor

        // Restart orbit animation for break duration (20 secs)
        OrbAnimations.stopOrbAnimation(orb)
        OrbAnimations.resetOrb(orb, around: mainView)
        orb.isHidden = false

        OrbAnimations.startOrbAnimation(orb, around: mainView, duration: 20)

        // Hide trail during break (optional, or recolor it too)
        trail?.isHidden = true
    }

    @objc private func handleStateChange(_ notification: Notification) {
        guard let isRunning = notification.object as? Bool else { return }
        orb?.isHidden = !isRunning

        if isRunning {
            guard let orb else { return }

            // Restore original orb color
            orb.backgroundColor = .systemPurple  // or whatever your default color is
            orb.layer.shadowColor = UIColor.systemPurple.cgColor  // match default

            let minutes = UserDefaults.standard.integer(forKey: "workModeMinutes")
            let duration = TimeInterval(minutes * 60)

            OrbAnimations.resetOrb(orb, around: mainView)
            trail?.isHidden = false
            trail.flatMap { OrbAnimations.stopTrailAnimation($0) }
            trail.flatMap { OrbAnimations.resetTrailAnimation($0) }
            OrbAnimations.startOrbAnimation(orb, around: mainView, duration: duration)
            trail.flatMap { OrbAnimations.startTrailAnimation($0, duration: duration) }
            modeToggle.setOn(true, animated: true)
        }
    }

    /// Every tick from the global timer — keep trail in sync with real elapsed time
    @objc private func handleTick(_ notification: Notification) {
        guard WorkModeTimerManager.shared.isRunning else { return }
        let minutes = UserDefaults.standard.integer(forKey: "workModeMinutes")
        let duration = TimeInterval(minutes * 60)
        let progress = WorkModeTimerManager.shared.progress()
        trail.flatMap { OrbAnimations.resumeTrailAnimation($0, duration: duration, progress: progress) }
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
