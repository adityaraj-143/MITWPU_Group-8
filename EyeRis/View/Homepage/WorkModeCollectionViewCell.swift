import UIKit

class WorkModeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var modeToggle: UISwitch!

    private var orb: UIView?
    override func awakeFromNib() {
        super.awakeFromNib()

        mainView.clipsToBounds = false
        mainView.layer.masksToBounds = false
        contentView.clipsToBounds = false
        self.clipsToBounds = false

        orb = OrbAnimations.attachOrb(to: contentView)

        // ✅ Fix initial visibility
        orb?.isHidden = !WorkModeTimerManager.shared.isRunning

        mainView.applyCornerRadius()
        iconView.makeRounded()
        modeToggle.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)

        modeToggle.isOn = WorkModeTimerManager.shared.isRunning

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTick(_:)),
            name: .workModeTick,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange(_:)),
            name: .workModeStateChanged,
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

        modeToggle.isOn = WorkModeTimerManager.shared.isRunning
        orb?.isHidden = !WorkModeTimerManager.shared.isRunning
    }
    
    @objc private func handleTick(_ notification: Notification) {

        guard let seconds = notification.object as? Int else { return }

        let total = UserDefaults.standard.integer(forKey: "workModeMinutes") * 60

        let progress = 1 - (CGFloat(seconds) / CGFloat(total))

        if let orb = orb {
            OrbAnimations.moveOrb(
                orb: orb,
                in: contentView,
                around: mainView,
                progress: progress
            )
        }
    }
    
    @objc private func handleStateChange(_ notification: Notification) {

        guard let isRunning = notification.object as? Bool else { return }

        orb?.isHidden = !isRunning
    }
}
