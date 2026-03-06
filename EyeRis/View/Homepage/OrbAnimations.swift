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

    static func resetOrb(orb: UIView, around card: UIView) {
        let rect = card.frame
        UIView.performWithoutAnimation {
            orb.center = CGPoint(x: rect.minX, y: rect.minY)
        }
    }

    static func startOrbAnimation(orb: UIView, around card: UIView, duration: TimeInterval) {
        let path = UIBezierPath(roundedRect: card.frame, cornerRadius: card.layer.cornerRadius)
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = duration
        animation.calculationMode = .paced
        animation.repeatCount = .infinity
        animation.rotationMode = .none

        orb.layer.add(animation, forKey: "orbPath")
    }

    static func stopOrbAnimation(orb: UIView) {
        orb.layer.removeAnimation(forKey: "orbPath")
    }

    static func attachTrail(to view: UIView, around card: UIView) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: card.frame, cornerRadius: card.layer.cornerRadius)
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

    static func startTrailAnimation(trail: CAShapeLayer, duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
 
        trail.add(animation, forKey: "trailProgress")
    }

    static func stopTrailAnimation(trail: CAShapeLayer) {
        trail.removeAnimation(forKey: "trailProgress")
        trail.strokeEnd = 0
    }

    // MARK: - Rocket Toast

    static func showWorkModeEnabledToast(in containerView: UIView, around card: UIView) {

        guard let window = containerView.window else { return }

        let cardRectInWindow = containerView.convert(card.frame, to: window)

        // MARK: Blur backdrop

        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: nil)
        blurView.frame = window.bounds
        blurView.alpha = 0
        window.addSubview(blurView)

        // MARK: SF Symbol rocket icon

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 44, weight: .medium)
        let rocketImage = UIImage(systemName: "sparkles", withConfiguration: symbolConfig)  // clean, professional

        let rocketView = UIImageView(image: rocketImage)
        rocketView.tintColor = .white
        rocketView.layer.shadowColor = UIColor.systemGreen.cgColor
        rocketView.layer.shadowRadius = 10
        rocketView.layer.shadowOpacity = 0.9
        rocketView.layer.shadowOffset = .zero
        rocketView.sizeToFit()

        // MARK: Text label

        let textLabel = UILabel()
        textLabel.text = "Work Mode Enabled"
        textLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        textLabel.textColor = .white
        textLabel.layer.shadowColor = UIColor.systemGreen.cgColor
        textLabel.layer.shadowRadius = 6
        textLabel.layer.shadowOpacity = 0.8
        textLabel.layer.shadowOffset = .zero
        textLabel.sizeToFit()

        // MARK: Stack in transparent wrapper

        let spacing: CGFloat = 8
        let containerWidth = max(rocketView.bounds.width, textLabel.bounds.width)
        let containerHeight = rocketView.bounds.height + spacing + textLabel.bounds.height

        let wrapper = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight))
        wrapper.backgroundColor = .clear

        rocketView.center = CGPoint(x: containerWidth / 2, y: rocketView.bounds.height / 2)
        textLabel.center = CGPoint(x: containerWidth / 2, y: rocketView.bounds.height + spacing + textLabel.bounds.height / 2)

        wrapper.addSubview(rocketView)
        wrapper.addSubview(textLabel)

        // MARK: Position

        let startY = cardRectInWindow.maxY + containerHeight
        let landY  = cardRectInWindow.minY - containerHeight * 0.8

        wrapper.center = CGPoint(x: cardRectInWindow.midX, y: startY)
        wrapper.alpha = 0
        wrapper.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        window.addSubview(wrapper)

        // MARK: Phase 1 — blur in + launch

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            blurView.effect = blurEffect
            blurView.alpha = 0.55
        }

        UIView.animate(
            withDuration: 0.42,
            delay: 0,
            usingSpringWithDamping: 0.52,
            initialSpringVelocity: 2.0,
            options: .curveEaseOut,
            animations: {
                wrapper.center = CGPoint(x: cardRectInWindow.midX, y: landY)
                wrapper.alpha = 1
                wrapper.transform = .identity
            }
        )

        // MARK: Phase 2 — rocket off + blur clears

        let holdDuration: Double = 0.9

        UIView.animate(withDuration: 0.4, delay: holdDuration, options: .curveEaseIn) {
            blurView.effect = nil
            blurView.alpha = 0
        } completion: { _ in
            blurView.removeFromSuperview()
        }

        UIView.animate(
            withDuration: 0.28,
            delay: holdDuration,
            options: .curveEaseIn,
            animations: {
                wrapper.center = CGPoint(x: cardRectInWindow.midX, y: -containerHeight * 4)
                wrapper.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                wrapper.alpha = 0
            },
            completion: { _ in
                wrapper.removeFromSuperview()
            }
        )
    }
}
