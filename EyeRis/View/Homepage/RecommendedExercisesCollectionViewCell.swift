//
//  RecommendedExercisesCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class RecommendedExercisesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconBG: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconBG.layer.cornerRadius = iconBG.bounds.height/2
        mainView.applyCornerRadius()
    }
    
    func configure(title: String, subtitle: String, icon: String, bgColor: UIColor, iconBG: UIColor) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconImage.image = UIImage(named: icon)
        mainView.backgroundColor = bgColor
        self.iconBG.backgroundColor = iconBG
    }

}
