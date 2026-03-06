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

    // MARK: - Rocket Toast with Blur Backdrop

    static func showWorkModeEnabledToast(in containerView: UIView, around card: UIView) {

        guard let window = containerView.window else { return }

        let cardRectInWindow = containerView.convert(card.frame, to: window)

        // MARK: Blur backdrop

        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: nil)
        blurView.frame = window.bounds
        blurView.alpha = 0
        window.addSubview(blurView)

        // MARK: Toast — light, frosted glass feel

        let toast = UIView()
        toast.backgroundColor = UIColor.white.withAlphaComponent(0.12)  // light + transparent
        toast.layer.cornerRadius = 20
        toast.layer.cornerCurve = .continuous
        toast.clipsToBounds = false
        toast.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        toast.layer.borderWidth = 1
        toast.layer.shadowColor = UIColor.systemGreen.cgColor
        toast.layer.shadowRadius = 18
        toast.layer.shadowOpacity = 0.5
        toast.layer.shadowOffset = .zero

        // Frosted glass inner blur
        let toastBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        toastBlur.layer.cornerRadius = 20
        toastBlur.layer.cornerCurve = .continuous
        toastBlur.clipsToBounds = true

        // Icon container
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.18)
        iconContainer.layer.cornerRadius = 14
        iconContainer.layer.cornerCurve = .continuous

        let iconLabel = UILabel()
        iconLabel.text = "🚀"
        iconLabel.font = UIFont.systemFont(ofSize: 26)
        iconLabel.sizeToFit()

        // Labels
        let titleLabel = UILabel()
        titleLabel.text = "Work Mode"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = UIColor.white

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Enabled"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor.systemGreen

        // Layout
        let iconSize: CGFloat = 52
        let padding: CGFloat = 16
        let textSpacing: CGFloat = 3
        let toastHeight: CGFloat = 76

        titleLabel.sizeToFit()
        subtitleLabel.sizeToFit()

        let textWidth = max(titleLabel.bounds.width, subtitleLabel.bounds.width)
        let toastWidth = padding + iconSize + padding * 0.75 + textWidth + padding

        toast.frame = CGRect(x: 0, y: 0, width: toastWidth, height: toastHeight)
        toastBlur.frame = toast.bounds

        iconContainer.frame = CGRect(x: padding, y: (toastHeight - iconSize) / 2, width: iconSize, height: iconSize)
        iconLabel.center = CGPoint(x: iconSize / 2, y: iconSize / 2)
        iconContainer.addSubview(iconLabel)

        let textX = padding + iconSize + padding * 0.75
        let totalTextHeight = titleLabel.bounds.height + textSpacing + subtitleLabel.bounds.height
        let textStartY = (toastHeight - totalTextHeight) / 2

        titleLabel.frame = CGRect(x: textX, y: textStartY, width: textWidth, height: titleLabel.bounds.height)
        subtitleLabel.frame = CGRect(
            x: textX,
            y: textStartY + titleLabel.bounds.height + textSpacing,
            width: textWidth,
            height: subtitleLabel.bounds.height
        )

        toast.addSubview(toastBlur)
        toast.addSubview(iconContainer)
        toast.addSubview(titleLabel)
        toast.addSubview(subtitleLabel)

        let startY = cardRectInWindow.maxY + toastHeight
        let landY  = cardRectInWindow.minY - toastHeight * 0.7

        toast.center = CGPoint(x: cardRectInWindow.midX, y: startY)
        toast.alpha = 0
        toast.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)

        window.addSubview(toast)

        // MARK: Phase 1 — blur in + toast launches

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
                toast.center = CGPoint(x: cardRectInWindow.midX, y: landY)
                toast.alpha = 1
                toast.transform = .identity
            }
        )

        // MARK: Phase 2 — hold shorter, then rocket off

        let holdDuration: Double = 0.9   // down from 1.5

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
                toast.center = CGPoint(x: cardRectInWindow.midX, y: -toastHeight * 4)
                toast.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                toast.alpha = 0
            },
            completion: { _ in
                toast.removeFromSuperview()
            }
        )
    }
}
