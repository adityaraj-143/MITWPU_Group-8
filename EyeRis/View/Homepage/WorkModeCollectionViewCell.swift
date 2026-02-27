import UIKit

class WorkModeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var modeToggle: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()

        mainView.applyCornerRadius()
        iconView.makeRounded()
        modeToggle.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)

        // Keep switch in sync with timer state
        modeToggle.isOn = WorkModeTimerManager.shared.isRunning
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
}
