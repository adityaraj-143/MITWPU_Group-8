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
    @IBOutlet weak var timerContainer: UIView!
    @IBOutlet weak var Header: UIView!
    @IBOutlet weak var Picker: UIPickerView!
    @IBOutlet weak var modeToggle: UISwitch!
    @IBOutlet weak var infoButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()

        Picker.dataSource = self
        Picker.delegate = self
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2   // minutes + seconds
    }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 60   // minutes: 0–59
        } else {
            return 60   // seconds: 0–59
        }
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return String(format: "%02d", row)
    }


}
