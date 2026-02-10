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
        mainView.makeRounded()
      
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mainView.clipsToBounds = true
        contentView.clipsToBounds = true
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        mainView.layer.borderWidth = 2
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        
    }
    
    func configure(image: UIImage, bgColor: UIColor) {
        iconImageView.image = image
        mainView.backgroundColor = bgColor
        mainView.layer.borderColor = bgColor.cgColor
    }
}


