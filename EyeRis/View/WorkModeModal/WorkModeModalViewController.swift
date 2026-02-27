import UIKit

class WorkModeModalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    
    private var timer: Timer?
    private var remainingSeconds: Int = 0
    private var endTime: Date?
    private var isBreakCycle = false
    private var initialDurationSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        timerLabel.isHidden = true
    }

    @IBAction func startTimerPressed(_ sender: UIButton) {
        let minutes = picker.selectedRow(inComponent: 0)
        guard minutes > 0 else { return }
        
        initialDurationSeconds = minutes * 60
        startWorkCycle()
    }

    private func startWorkCycle() {
        isBreakCycle = false
        remainingSeconds = initialDurationSeconds
        endTime = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        
        updateTimerLabel()
        timerLabel.isHidden = false
        picker.isHidden = true
        
        startTicking()
    }

    private func startBreakCycle() {
        isBreakCycle = true
        remainingSeconds = 20
        endTime = Date().addingTimeInterval(20)
        
        timerLabel.text = "Time’s up.\nLook away for 20 secs."
        timerLabel.isHidden = false
        picker.isHidden = true
        
        startTicking()
    }

    private func startTicking() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(tick),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc private func tick() {
        guard let endTime = endTime else { return }
        let secondsLeft = Int(ceil(endTime.timeIntervalSinceNow))

        if secondsLeft <= 0 {
            fireCompletionHaptics()

            if isBreakCycle {
                dismiss(animated: true) // or reset if you prefer
            } else {
                startBreakCycle()
            }
            return
        }

        remainingSeconds = secondsLeft
        updateTimerLabel()
    }

    private func updateTimerLabel() {
        if isBreakCycle {
            timerLabel.text = "Look away\n\(remainingSeconds)s"
        } else {
            let minutes = remainingSeconds / 60
            let seconds = remainingSeconds % 60
            timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func fireCompletionHaptics() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            generator.notificationOccurred(.success)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    // MARK: - PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return 90 }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row) min"
    }
}
