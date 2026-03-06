import UIKit

class WorkModeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var modeToggle: UISwitch!

    private var orb: UIView?
    private var trail: CAShapeLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        configureOrb()
        trail = OrbAnimations.attachTrail(to: contentView, around: mainView)
        configureObservers()
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
        }
    }

    // MARK: - Notification

    @objc private func handleStateChange(_ notification: Notification) {
        guard let isRunning = notification.object as? Bool else { return }
        orb?.isHidden = !isRunning
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        modeToggle.isOn = WorkModeTimerManager.shared.isRunning
        orb?.isHidden = !WorkModeTimerManager.shared.isRunning
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
