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
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        iconBG.layer.cornerRadius = iconBG.bounds.height / 2
        mainView.applyCornerRadius()

        // 🔥 FIX
        IconImage.tintColor = .white
    }

    func configure(
        title: String,
        subtitle: String,
        icon: UIImage,
        bgColor: UIColor,
        iconBG: UIColor
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle

        // 🔥 FIX
        IconImage.image = icon.withRenderingMode(.alwaysTemplate)

        mainView.backgroundColor = bgColor
        self.iconBG.backgroundColor = iconBG
    }
}
