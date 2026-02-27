
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
    
//    @IBOutlet weak var exerciseDescription: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var StyleContainerView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var checkmark: UIButton!
    @IBOutlet weak var exerciseImpact: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.clipsToBounds = false
        contentView.clipsToBounds = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        cardView.addGestureRecognizer(tap)
        cardView.isUserInteractionEnabled = true

        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        iconView.makeRounded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    var onTapNavigation: (() -> Void)?

    @objc private func cardTapped() {
        onTapNavigation?()
    }

    
    func configure(with item: TodaysExercise) {
        exercise = item.exercise
        exerciseName.text = item.exercise.name
        exerciseImage.image = UIImage(named: item.exercise.getIcon())
        durationLabel.text = "\(item.exercise.duration) sec"
        iconView.backgroundColor = item.exercise.getIconBGColor()
        exerciseImpact.text = item.exercise.getImpact()

        if item.isCompleted {
            checkmark.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            checkmark.tintColor = .lightGreen
        } else {
            checkmark.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            checkmark.layer.opacity = 0
        }
    }

}
