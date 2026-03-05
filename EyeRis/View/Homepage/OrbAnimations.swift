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
    
    static func attachTrail(to view: UIView, around card: UIView) -> CAShapeLayer {

        let path = UIBezierPath(
            roundedRect: card.frame,
            cornerRadius: card.layer.cornerRadius
        )

        let trail = CAShapeLayer()
        trail.path = path.cgPath
        trail.fillColor = UIColor.clear.cgColor
        trail.strokeColor = UIColor.systemGreen.cgColor
        trail.lineWidth = 2

        trail.strokeStart = 0
        trail.strokeEnd = 0

        trail.shadowColor = UIColor.systemGreen.cgColor
        trail.shadowRadius = 6
        trail.shadowOpacity = 0.8
        trail.shadowOffset = .zero

        view.layer.addSublayer(trail)

        return trail
    }
    
    static func startTrailAnimation(
        trail: CAShapeLayer,
        duration: TimeInterval
    ) {

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        // match orb offset
        animation.timeOffset = -duration * 0.02

        trail.add(animation, forKey: "trailProgress")
    }
    
    static func stopTrailAnimation(trail: CAShapeLayer) {

        trail.removeAnimation(forKey: "trailProgress")
        trail.strokeEnd = 0
    }
    
}
