//
//  RecommendedExercisesCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class ExerciseListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconBG: UIView!
    @IBOutlet weak var IconImage: UIImageView!
    @IBOutlet weak var impactLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        iconBG.layer.cornerRadius = iconBG.bounds.height / 2
        mainView.applyCornerRadius()

        IconImage.tintColor = .white
    }

    func configure(
        title: String,
        impact: String,
        icon: String,
        iconBG: UIColor
    ) {
        titleLabel.text = title
        impactLabel.text = impact
        IconImage.image = UIImage(named: icon)
        self.iconBG.backgroundColor = iconBG
    }
}

