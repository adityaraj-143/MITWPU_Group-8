//
//  ExerciseCell.swift
//  EyeRis
//
//  Created by SDC-USER on 13/01/26.
//


import UIKit

final class ExerciseCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        durationLabel.text = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        
    }
    
    override func awakeFromNib() {
            super.awakeFromNib()
            
            // ✅ Call your existing helper here
            contentView.applyCornerRadius()
        }


    // MARK: - Configuration

    func configure(
        title: String,
        subtitle: String,
        duration: String,
        iconName: String
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        durationLabel.text = duration
        iconImageView.image = UIImage(systemName: iconName)
    }
}
