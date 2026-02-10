//
//  ChatMessageCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 10/02/26.
//

import UIKit

class ChatMessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bubbleView.layer.cornerRadius = 16
        messageLabel.numberOfLines = 0
    }
    
    
    func configure(text: String, isIncoming: Bool) {
        messageLabel.text = text

        if isIncoming {
            bubbleView.backgroundColor = .systemGray5
            messageLabel.textColor = .black

            // LEFT aligned
            leadingConstraint.constant = 16
            trailingConstraint.constant = 120
        } else {
            bubbleView.backgroundColor = .systemBlue
            messageLabel.textColor = .white

            // RIGHT aligned
            leadingConstraint.constant = 120
            trailingConstraint.constant = 16
        }
    }


}
