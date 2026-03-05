//
//  OrbAnimations.swift
//  EyeRis
//
//  Created by SDC-USER on 05/03/26.
//


import UIKit

class OrbAnimations {

    static func attachOrb(to view: UIView) -> UIView {

        let orb = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))

        orb.backgroundColor = .systemGreen
        orb.layer.cornerRadius = 5

        orb.layer.shadowColor = UIColor.systemGreen.cgColor
        orb.layer.shadowRadius = 8
        orb.layer.shadowOpacity = 1
        orb.layer.shadowOffset = .zero

        view.addSubview(orb)

        return orb
    }
    
    static func moveOrb(
        orb: UIView,
        in view: UIView,
        progress: CGFloat
    ) {

        let rect = view.bounds
        print(rect.height,rect.width)
        let perimeter =
            (rect.width * 2) +
            (rect.height * 2)

        let distance = perimeter * progress

        var x: CGFloat = 0
        var y: CGFloat = 0

        if distance < rect.width {

            x = distance
            y = 0

        } else if distance < rect.width + rect.height {

            x = rect.width
            y = distance - rect.width

        } else if distance < rect.width * 2 + rect.height {

            x = rect.width - (distance - rect.width - rect.height)
            y = rect.height

        } else {

            x = 0
            y = rect.height - (distance - rect.width * 2 - rect.height)
        }

        orb.center = CGPoint(x: x, y: y)
    }

}
