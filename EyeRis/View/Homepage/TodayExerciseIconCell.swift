//
//  TodayExerciseIconsCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class TodayExerciseIconCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.layer.cornerRadius = mainView.bounds.height / 2
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mainView.clipsToBounds = true        // 🔥 important
        contentView.clipsToBounds = true
        mainView.layer.borderWidth = 2
        mainView.layer.borderColor = UIColor.lightGreen.cgColor
        iconImageView.contentMode = .scaleAspectFit

    }
    
    func configure(image: UIImage) {
        iconImageView.image = image
    }
}


