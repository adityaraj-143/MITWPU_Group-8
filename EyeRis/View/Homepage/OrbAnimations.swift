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


    static func resetOrb(
        orb: UIView,
        around card: UIView
    ) {
        let rect = card.frame
        let startX = rect.minX
        let startY = rect.minY

        UIView.performWithoutAnimation {
            orb.center = CGPoint(x: startX, y: startY)
        }
    }
    
    
    static func startOrbAnimation(
        orb: UIView,
        around card: UIView,
        duration: TimeInterval
    ) {

        let path = UIBezierPath(
            roundedRect: card.frame,
            cornerRadius: card.layer.cornerRadius
        )

        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = duration
        animation.calculationMode = .paced
        animation.repeatCount = .infinity
        animation.rotationMode = .none

        // small offset so it starts exactly at visual top-left
        animation.timeOffset = -duration * 0.02

        orb.layer.add(animation, forKey: "orbPath")
    }
    
    static func stopOrbAnimation(orb: UIView) {
        orb.layer.removeAnimation(forKey: "orbPath")
    }
    
}
