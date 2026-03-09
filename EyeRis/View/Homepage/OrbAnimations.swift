import UIKit

class OrbAnimations {

    // MARK: - Orb

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

    static func resetOrb(_ orb: UIView, around card: UIView) {
        UIView.performWithoutAnimation {
            orb.center = CGPoint(x: card.frame.minX, y: card.frame.minY)
        }
    }

    static func startOrbAnimation(_ orb: UIView, around card: UIView, duration: TimeInterval) {
        let path = UIBezierPath(roundedRect: card.frame, cornerRadius: card.layer.cornerRadius)

        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = duration
        animation.calculationMode = .paced
        animation.repeatCount = .infinity
        animation.rotationMode = .none

        orb.layer.add(animation, forKey: "orbPath")
    }

    static func stopOrbAnimation(_ orb: UIView) {
        orb.layer.removeAnimation(forKey: "orbPath")
    }

    static func resumeOrbAnimation(_ orb: UIView, around card: UIView, duration: TimeInterval, progress: Double) {
        let path = UIBezierPath(roundedRect: card.frame, cornerRadius: card.layer.cornerRadius)

        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = duration
        animation.calculationMode = .paced
        animation.repeatCount = .infinity
        animation.timeOffset = duration * progress

        orb.layer.add(animation, forKey: "orbPath")
    }

    // MARK: - Trail

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

    static func startTrailAnimation(_ trail: CAShapeLayer, duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.repeatCount = .infinity    // ← this is the key change
        animation.isRemovedOnCompletion = false

        trail.add(animation, forKey: "trailProgress")
    }

    static func resumeTrailAnimation(_ trail: CAShapeLayer, duration: TimeInterval, progress: Double) {
        trail.removeAnimation(forKey: "trailProgress")

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.repeatCount = .infinity    // ← same here
        animation.isRemovedOnCompletion = false
        animation.timeOffset = duration * progress

        trail.strokeEnd = CGFloat(progress)
        trail.add(animation, forKey: "trailProgress")
    }


    /// Resumes trail from `progress` using the same timeOffset trick as the orb,
    /// so they stay in lockstep after switching screens.


    static func stopTrailAnimation(_ trail: CAShapeLayer) {
        trail.removeAnimation(forKey: "trailProgress")
        trail.removeAnimation(forKey: "trailWipe")
        trail.strokeEnd = 0
        trail.strokeStart = 0
    }

    // MARK: - Work Mode Toast

    static func showWorkModeEnabledToast(in containerView: UIView, around card: UIView) {
        guard let window = containerView.window else { return }

        let cardFrame = containerView.convert(card.frame, to: window)

        // Blur backdrop
        let backdrop = UIVisualEffectView(effect: nil)
        backdrop.frame = window.bounds
        backdrop.alpha = 0
        window.addSubview(backdrop)

        // Icon
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 44, weight: .medium)
        let iconImage = UIImage(systemName: "sparkles", withConfiguration: iconConfig)
        let iconView = UIImageView(image: iconImage)
        iconView.tintColor = .label
        iconView.layer.shadowColor = UIColor.systemGreen.cgColor
        iconView.layer.shadowRadius = 12
        iconView.layer.shadowOpacity = 0.9
        iconView.layer.shadowOffset = .zero
        iconView.sizeToFit()

        // Label
        let label = UILabel()
        label.text = "Work Mode Enabled"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.layer.shadowColor = UIColor.systemGreen.cgColor
        label.layer.shadowRadius = 8
        label.layer.shadowOpacity = 0.8
        label.layer.shadowOffset = .zero
        label.sizeToFit()

        // Wrapper
        let spacing: CGFloat = 8
        let wrapperWidth = max(iconView.bounds.width, label.bounds.width)
        let wrapperHeight = iconView.bounds.height + spacing + label.bounds.height

        let toast = UIView(frame: CGRect(x: 0, y: 0, width: wrapperWidth, height: wrapperHeight))
        toast.backgroundColor = .clear

        iconView.center = CGPoint(x: wrapperWidth / 2, y: iconView.bounds.height / 2)
        label.center = CGPoint(x: wrapperWidth / 2, y: iconView.bounds.height + spacing + label.bounds.height / 2)

        toast.addSubview(iconView)
        toast.addSubview(label)

        let startY = window.bounds.maxY + wrapperHeight
        let landY  = window.bounds.midY

        toast.center = CGPoint(x: window.bounds.midX, y: startY)
        toast.alpha = 0
        toast.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        window.addSubview(toast)

        // Phase 1 — backdrop fades in, toast launches up
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            backdrop.effect = UIBlurEffect(style: .systemUltraThinMaterial)
            backdrop.alpha = 0.55
        }

        UIView.animate(
            withDuration: 0.42,
            delay: 0,
            usingSpringWithDamping: 0.52,
            initialSpringVelocity: 2.0,
            options: .curveEaseOut
        ) {
            toast.center = CGPoint(x: window.bounds.midX, y: landY)
            toast.alpha = 1
            toast.transform = .identity
        }

        // Phase 2 — hold, then toast shoots off and backdrop clears
        let holdDuration: Double = 0.9

        UIView.animate(withDuration: 0.4, delay: holdDuration, options: .curveEaseIn) {
            backdrop.effect = nil
            backdrop.alpha = 0
        } completion: { _ in
            backdrop.removeFromSuperview()
        }

        UIView.animate(withDuration: 0.28, delay: holdDuration, options: .curveEaseIn) {
            toast.center = CGPoint(x: window.bounds.midX, y: -wrapperHeight * 4)
            toast.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            toast.alpha = 0
        } completion: { _ in
            toast.removeFromSuperview()
        }
    }
}
