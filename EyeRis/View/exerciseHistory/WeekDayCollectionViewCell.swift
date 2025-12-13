//
//  WeekdayCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class WeekdayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var weekdayButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainView.clipsToBounds = true
        
        // Button text alignment
        weekdayButton.titleLabel?.textAlignment = .center
        weekdayButton.isUserInteractionEnabled = true
        weekdayButton.setTitleColor(.black, for: .normal)
        // ^ Important: selection should be handled by collectionView, not button taps
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = min(mainView.bounds.width, mainView.bounds.height) / 2.0
        mainView.layer.cornerRadius = radius
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset visual state
        mainView.backgroundColor = .white
        weekdayButton.setTitleColor(.black, for: .normal)
        weekdayButton.setTitle(nil, for: .normal)
    }
    
    func configureCell(letter: String, isSelected: Bool) {
        weekdayButton.setTitle(letter, for: .normal)
        
//        mainView.backgroundColor = isSelected ? .systemBlue : .white
//        weekdayButton.setTitleColor(isSelected ? .white : .black, for: .normal)
    }
    
    @IBAction func weekdayTapped(_ sender: UIButton) {
        weekdayButton.setTitleColor(.systemBlue, for: .normal)
    }
}
