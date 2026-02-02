
//  TodaysExerciseCardCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class TodaysExerciseSetCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = " exercise__set_cell"
    var exercise: Exercise?
    
    @IBOutlet weak var exerciseName: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var exerciseImage: UIImageView!
    @IBOutlet weak var exerciseDescription: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var StyleContainerView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var checkmark: UIImageView!
    @IBOutlet weak var navigationButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.clipsToBounds = false
        contentView.clipsToBounds = false

        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.backgroundColor = UIColor(white: 0.98, alpha: 1)

//        StyleContainerView.applyShadow()
//        navigationButton.backgroundColor = .lightGreen

        iconView.makeRounded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        exerciseDescription.preferredMaxLayoutWidth = exerciseDescription.frame.width
    }
    
    var onTapNavigation: (() -> Void)?

    @IBAction func startButton(_ sender: Any) {
        onTapNavigation?()
    }
    
    func configure(with item: TodaysExercise) {
        exercise = item.exercise
        exerciseName.text = item.exercise.name
        exerciseDescription.text = item.exercise.instructions.description
        exerciseImage.image = UIImage(named: item.exercise.getIcon())
        durationLabel.text = "\(item.exercise.duration) sec"
        cardView.backgroundColor = .white
        iconView.backgroundColor = item.exercise.getIconBGColor()

        if item.isCompleted {
            checkmark.image = UIImage(systemName: "checkmark.circle.fill")
            checkmark.tintColor = .lightGreen
        } else {
            checkmark.image = UIImage(systemName: "checkmark.circle")
            checkmark.tintColor = .systemGray
        }
    }

}
