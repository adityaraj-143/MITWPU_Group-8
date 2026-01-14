//
//  SectionHeaderCollectionReusableView.swift
//  EyeRis
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class SectionHeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var NavigateButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

        let font = UIFont.systemFont(ofSize: 14)
        let color = UIColor.black

        let currentTitle = NavigateButton.attributedTitle(for: .normal)?.string ?? "See all"

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]

        let attributedTitle = NSAttributedString(string: currentTitle, attributes: attrs)

        NavigateButton.setAttributedTitle(attributedTitle, for: .normal)
        NavigateButton.setAttributedTitle(attributedTitle, for: .highlighted)
        NavigateButton.setAttributedTitle(attributedTitle, for: .selected)
        NavigateButton.setAttributedTitle(attributedTitle, for: .disabled)
    }


    
    func congfigure(headerText: String, hideNav: Bool = false) {
        headerLabel.text = headerText
        NavigateButton.isHidden = hideNav
    }
    
}
