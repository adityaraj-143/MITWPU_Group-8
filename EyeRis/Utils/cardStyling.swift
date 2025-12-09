//
//  cardStyling.swift
//  EyeRis
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

func setCornerRadius(_ view: UIView) {
    view.layer.cornerRadius = 17
}

func setCornerRadius(_ views: [UIView]) {
    for view in views {
        setCornerRadius(view)
    }
}


func setShadows(_ view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.1
    view.layer.shadowRadius = 10
    view.layer.shadowOffset = .zero
    view.layer.masksToBounds = false
}

func setShadows(_ views: [UIView]) {
    for view in views{
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = .zero
        view.layer.masksToBounds = false
    }
    
}
