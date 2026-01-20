//
//  TodayExerciseCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class TodayExerciseCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var todaysExerciseLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.applyCornerRadius()
    }
    
    func configure(with item: TodaysExerciseItem) {
        todaysExerciseLabel.text = "abc"
        instructionLabel.text = "abc"
        timeLabel.text = "1 min" // TEMP (can improve later)
        // icon handled later
    }
}
