//
//  TestsCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class TestsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconBG: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.applyCornerRadius()
        iconBG.layer.cornerRadius = iconBG.bounds.height/2
    }
    
    func configure(title: String, subtitle: String, icon: String ) {
        titleLabel.text = title
        iconImage.image = UIImage(named: icon)
        subtitleLabel.text = subtitle
    }

}
