import UIKit

class WorkModeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var modeToggle: UISwitch!

    private var orb: UIView?
    override func awakeFromNib() {
        super.awakeFromNib()
        orb = OrbAnimations.attachOrb(to: mainView)
        mainView.applyCornerRadius()
        iconView.makeRounded()
        modeToggle.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)

        // Keep switch in sync with timer state
        modeToggle.isOn = WorkModeTimerManager.shared.isRunning
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTick(_:)),
            name: .workModeTick,
            object: nil
        )
    }

    @IBAction func modeToggleChanged(_ sender: UISwitch) {
        print("Switch toggled:", sender.isOn)

        if sender.isOn {
            print("Starting timer")
            WorkModeTimerManager.shared.start()
        } else {
            print("Stopping timer")
            WorkModeTimerManager.shared.stop()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // Sync switch again when reused
        modeToggle.isOn = WorkModeTimerManager.shared.isRunning
    }
    
    @objc private func handleTick(_ notification: Notification) {

        guard let seconds = notification.object as? Int else { return }

        let total = UserDefaults.standard.integer(forKey: "workModeMinutes") * 60

        let progress = 1 - (CGFloat(seconds) / CGFloat(total))

        if let orb = orb {
            OrbAnimations.moveOrb(
                orb: orb,
                in: mainView,
                progress: progress
            )
        }
    }
}
