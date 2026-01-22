
//  TodaysExerciseCardCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class TodaysExerciseSetCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = " exercise__set_cell"
    
    @IBOutlet weak var exerciseName: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var exerciseImage: UIImageView!
    @IBOutlet weak var exerciseDescription: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var StyleContainerView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var checkmark: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.clipsToBounds = false
        contentView.clipsToBounds = false

        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.backgroundColor = UIColor(white: 0.98, alpha: 1)

        StyleContainerView.applyShadow()

        iconView.makeRounded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        exerciseDescription.preferredMaxLayoutWidth = exerciseDescription.frame.width
    }

    func configure(with item: TodaysExerciseItem) {
        exerciseName.text = item.name
        exerciseDescription.text = item.instruction
        exerciseImage.image = UIImage(named: item.icon)
        durationLabel.text = item.duration

        if item.isCompleted {
            checkmark.image = UIImage(systemName: "checkmark.circle.fill")
            checkmark.tintColor = .systemGreen
        } else {
            checkmark.image = UIImage(systemName: "checkmark.circle")
            checkmark.tintColor = .systemGray
        }
    }

}
