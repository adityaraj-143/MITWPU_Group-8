//
//  WorkModeCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 10/02/26.
//

import UIKit

class WorkModeCollectionViewCell: UICollectionViewCell,
                                  UIPickerViewDataSource,
                                  UIPickerViewDelegate {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var timerContainer: UIView!
    @IBOutlet weak var Header: UIView!
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var modeToggle: UISwitch!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    
    @IBAction func modeToggleChanged(_ sender: UISwitch) {
        if sender.isOn {
            startTimerFromPicker()
        } else {
            stopTimer()
        }
    }
    
    

    private var isBreakCycle = false

    private var timer: Timer?
    private var remainingSeconds: Int = 0
    private var endTime: Date?
    
    private var initialDurationSeconds: Int = 0


    
    private func startTimerFromPicker() {
        let minutes = picker.selectedRow(inComponent: 0)

        guard minutes > 0 else {
            modeToggle.setOn(false, animated: true)
            return
        }

        // 🔥 THIS LINE WAS MISSING
        initialDurationSeconds = minutes * 60

        remainingSeconds = initialDurationSeconds
        endTime = Date().addingTimeInterval(TimeInterval(remainingSeconds))

        picker.isHidden = true
        timerLabel.isHidden = false
        textLabel.isHidden = true

        updateTimerLabel()

        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(tick),
            userInfo: nil,
            repeats: true
        )
    }

    
    private func fireCompletionHaptics() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()

        generator.notificationOccurred(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            generator.notificationOccurred(.success)
        }
    }
    
    private func startBreakCycle() {
        isBreakCycle = true

        remainingSeconds = 20
        endTime = Date().addingTimeInterval(20)

        applyBreakStyle()

        timerLabel.isHidden = false
        picker.isHidden = true
        textLabel.isHidden = true

        timerLabel.text = "Time’s up.\nLook away for 20 secs."

        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(tick),
            userInfo: nil,
            repeats: true
        )
    }

    
    private func applyWorkStyle() {
        timerLabel.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        timerLabel.numberOfLines = 1
        timerLabel.textAlignment = .center
    }

    private func applyBreakStyle() {
        timerLabel.font = UIFont.systemFont(ofSize: 27, weight: .semibold)
        timerLabel.numberOfLines = 2
        timerLabel.textAlignment = .center
    }
    

    @objc private func tick() {
        guard let endTime = endTime else { return }

        let secondsLeft = Int(ceil(endTime.timeIntervalSinceNow))

        if secondsLeft <= 0 {

            fireCompletionHaptics()   // 🔥 Always fire

            if isBreakCycle {
                // 👀 Break finished → go back to work
                isBreakCycle = false
                startNewCycle()
            } else {
                // 🧠 Work finished → go to break
                startBreakCycle()
            }
            return
        }

        remainingSeconds = secondsLeft

        if isBreakCycle {
            timerLabel.text = "Look away\n\(remainingSeconds)s"
        } else {
            updateTimerLabel()
        }
    }

    

    private func updateTimerLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        endTime = nil
        isBreakCycle = false

        picker.isHidden = false
        timerLabel.isHidden = true
        textLabel.isHidden = false
    }


    private func startNewCycle() {
        isBreakCycle = false

        applyWorkStyle()

        remainingSeconds = initialDurationSeconds
        endTime = Date().addingTimeInterval(TimeInterval(remainingSeconds))

        picker.isHidden = true
        timerLabel.isHidden = false

        updateTimerLabel()

        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(tick),
            userInfo: nil,
            repeats: true
        )
    }




    override func awakeFromNib() {
        super.awakeFromNib()

        picker.dataSource = self
        picker.delegate = self
        timerLabel.isHidden = true
        picker.isHidden = false
        
        mainView.applyCornerRadius()

        
        modeToggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
       

    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1   // ONLY minutes
    }


    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return 90   // 0–89 minutes
    }


    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {

        let label: UILabel

        if let reused = view as? UILabel {
            label = reused
        } else {
            label = UILabel()
            label.textAlignment = .center
        }

        label.text = "\(row) min"

        // FONT CONTROL HERE
        label.font = UIFont.systemFont(
            ofSize: 16,
            weight: .medium
        )

        label.textColor = .label

        return label
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopTimer()
        modeToggle.setOn(false, animated: false)
    }




}
