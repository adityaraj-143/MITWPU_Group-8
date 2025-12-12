//
//  WeekDayCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class WeekDayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellContainerView: UIView!
    @IBOutlet weak var weekDay: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellContainerView.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cellContainerView.layer.cornerRadius = cellContainerView.bounds.height / 2
    }
}
