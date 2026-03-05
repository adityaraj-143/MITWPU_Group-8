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
        in container: UIView,
        around card: UIView,
        progress: CGFloat
    ) {

        // Card frame inside the container (contentView)
        let rect = card.frame

        let perimeter =
            (rect.width * 2) +
            (rect.height * 2)

        let distance = perimeter * progress

        var x: CGFloat = 0
        var y: CGFloat = 0

        if distance < rect.width {

            x = rect.minX + distance
            y = rect.minY

        } else if distance < rect.width + rect.height {

            x = rect.maxX
            y = rect.minY + (distance - rect.width)

        } else if distance < rect.width * 2 + rect.height {

            x = rect.maxX - (distance - rect.width - rect.height)
            y = rect.maxY

        } else {

            x = rect.minX
            y = rect.maxY - (distance - rect.width * 2 - rect.height)
        }

        orb.center = CGPoint(x: x, y: y)
    }
}
