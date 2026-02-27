import UIKit

class WorkModeModalViewController: UIViewController,
                                    UIPickerViewDelegate,
                                    UIPickerViewDataSource {

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var timerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        picker.dataSource = self

        let savedMinutes = UserDefaults.standard.integer(forKey: "workModeMinutes")
        picker.selectRow(savedMinutes, inComponent: 0, animated: false)

        timerLabel.isHidden = true

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

    @objc private func handleStateChange(_ notification: Notification) {
        guard let isRunning = notification.object as? Bool else { return }

        if isRunning {
            picker.isHidden = true
            timerLabel.isHidden = false
        } else {
            picker.isHidden = false
            timerLabel.isHidden = true
        }
    }

    @objc private func handleTick(_ notification: Notification) {
        guard let seconds = notification.object as? Int else { return }

        let min = seconds / 60
        let sec = seconds % 60
        timerLabel.text = String(format: "%02d:%02d", min, sec)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Picker

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int { 90 }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        "\(row) min"
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        UserDefaults.standard.set(row, forKey: "workModeMinutes")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if WorkModeTimerManager.shared.isRunning {
            picker.isHidden = true
            timerLabel.isHidden = false

            // Also immediately update label
            updateImmediately()
        } else {
            picker.isHidden = false
            timerLabel.isHidden = true
        }
    }
    
    private func updateImmediately() {
        if let seconds = WorkModeTimerManager.shared.currentRemainingSeconds {
            let min = seconds / 60
            let sec = seconds % 60
            timerLabel.text = String(format: "%02d:%02d", min, sec)
        }
    }
    
    
}
