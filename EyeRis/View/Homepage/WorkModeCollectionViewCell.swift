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

    
    private var timer: Timer?
    private var remainingSeconds: Int = 0
    private var endTime: Date?
    

    
    private func startTimerFromPicker() {
        let minutes = picker.selectedRow(inComponent: 0)

        guard minutes > 0 else {
            modeToggle.setOn(false, animated: true)
            return
        }

        remainingSeconds = minutes * 60
        endTime = Date().addingTimeInterval(TimeInterval(remainingSeconds))

        // UI switch
        picker.isHidden = true
        timerLabel.isHidden = false
        textLabel.isHidden = true
        

        updateTimerLabel()

        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(tick),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func tick() {
        guard let endTime = endTime else { return }

        let secondsLeft = Int(endTime.timeIntervalSinceNow)

        if secondsLeft <= 0 {
            stopTimer()
            return
        }

        remainingSeconds = secondsLeft
        updateTimerLabel()
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

        picker.isHidden = false
        timerLabel.isHidden = true
        textLabel.isHidden = false
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
