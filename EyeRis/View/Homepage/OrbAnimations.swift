import UIKit

// MARK: - Orb Phase

enum OrbPhase {
    case work
    case rest
    
    var color: UIColor {
        switch self {
        case .work: return .systemGreen
        case .rest: return .systemOrange
        }
    }
}

// MARK: - Orb Animations

final class OrbAnimations {
    
    private static let orbSize: CGFloat = 10
    private static let animationKey = "pathAnimation"
    
    /// Minimum animation duration to prevent instant/glitchy animations
    private static let minimumAnimationDuration: TimeInterval = 1.0
    
    // MARK: - Create Orb
    
    static func createOrb(in view: UIView) -> UIView {
        let orb = UIView(frame: CGRect(x: 0, y: 0, width: orbSize, height: orbSize))
        orb.layer.cornerRadius = orbSize / 2
        orb.isHidden = true
        view.addSubview(orb)
        return orb
    }
    
    // MARK: - Create Trail
    
    static func createTrail(in view: UIView) -> CAShapeLayer {
        let trail = CAShapeLayer()
        trail.fillColor = UIColor.clear.cgColor
        trail.lineWidth = 2
        trail.strokeStart = 0
        trail.strokeEnd = 0
        trail.isHidden = true
        view.layer.addSublayer(trail)
        return trail
    }
    
    // MARK: - Build Path
    
    /// Creates the path around the card. Both orb and trail use this exact same path.
    private static func buildPath(around card: UIView) -> UIBezierPath {
        return UIBezierPath(roundedRect: card.frame, cornerRadius: card.layer.cornerRadius)
    }
    
    // MARK: - Apply Colors
    
    private static func applyColors(orb: UIView, trail: CAShapeLayer, phase: OrbPhase) {
        let color = phase.color
        
        // Orb
        orb.backgroundColor = color
        orb.layer.shadowColor = color.cgColor
        orb.layer.shadowRadius = 8
        orb.layer.shadowOpacity = 1
        orb.layer.shadowOffset = .zero
        
        // Trail
        trail.strokeColor = color.cgColor
        trail.shadowColor = color.cgColor
        trail.shadowRadius = 6
        trail.shadowOpacity = 0.8
        trail.shadowOffset = .zero
    }
    
    // MARK: - Start Animation
    
    /// Starts both orb and trail animations from the beginning (progress = 0).
    static func start(
        orb: UIView,
        trail: CAShapeLayer,
        around card: UIView,
        duration: TimeInterval,
        phase: OrbPhase
    ) {
        animate(orb: orb, trail: trail, around: card, duration: duration, phase: phase, progress: 0)
    }
    
    // MARK: - Resume Animation
    
    /// Resumes both orb and trail animations at a given progress (0.0 to 1.0).
    /// Also used when layout changes (rotation) to recalculate path and continue.
    static func resume(
        orb: UIView,
        trail: CAShapeLayer,
        around card: UIView,
        duration: TimeInterval,
        phase: OrbPhase,
        progress: Double
    ) {
        animate(orb: orb, trail: trail, around: card, duration: duration, phase: phase, progress: progress)
    }
    
    // MARK: - Stop Animation
    
    static func stop(orb: UIView, trail: CAShapeLayer) {
        // Remove all animations
        orb.layer.removeAnimation(forKey: animationKey)
        trail.removeAnimation(forKey: animationKey)
        
        // Reset trail
        trail.strokeEnd = 0
        trail.strokeStart = 0
        
        // Hide
        orb.isHidden = true
        trail.isHidden = true
    }
    
    // MARK: - Core Animation Logic
    
    /// The single source of truth for animating orb and trail.
    /// Both use the same path, same duration, same progress.
    private static func animate(
        orb: UIView,
        trail: CAShapeLayer,
        around card: UIView,
        duration: TimeInterval,
        phase: OrbPhase,
        progress: Double
    ) {
        // Safeguard: Ensure duration is valid to prevent instant/glitchy animations
        let safeDuration = max(duration, minimumAnimationDuration)
        let safeProgress = max(0, min(progress, 1))
        
        // 1. Stop any existing animations
        orb.layer.removeAnimation(forKey: animationKey)
        trail.removeAnimation(forKey: animationKey)
        
        // 2. Build fresh path from current card frame
        let path = buildPath(around: card)
        
        // 3. Apply colors
        applyColors(orb: orb, trail: trail, phase: phase)
        
        // 4. Update trail path
        trail.path = path.cgPath
        trail.strokeEnd = 0
        
        // 5. Show both
        orb.isHidden = false
        trail.isHidden = false
        
        // 6. Calculate time offset from progress
        let timeOffset = safeDuration * safeProgress
        
        // 7. Animate orb position along path
        let orbAnimation = CAKeyframeAnimation(keyPath: "position")
        orbAnimation.path = path.cgPath
        orbAnimation.duration = safeDuration
        orbAnimation.calculationMode = .paced
        orbAnimation.repeatCount = .infinity
        orbAnimation.isRemovedOnCompletion = false
        orbAnimation.fillMode = .forwards
        orbAnimation.timeOffset = timeOffset
        
        orb.layer.add(orbAnimation, forKey: animationKey)
        
        // 8. Animate trail strokeEnd from 0 to 1
        let trailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        trailAnimation.fromValue = 0
        trailAnimation.toValue = 1
        trailAnimation.duration = safeDuration
        trailAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        trailAnimation.repeatCount = .infinity
        trailAnimation.isRemovedOnCompletion = false
        trailAnimation.fillMode = .forwards
        trailAnimation.timeOffset = timeOffset
        
        trail.add(trailAnimation, forKey: animationKey)
    }
    
    // MARK: - Toast
    
    static func showWorkModeEnabledToast(in containerView: UIView) {
        guard let window = containerView.window else { return }
        
        let backdrop = UIVisualEffectView(effect: nil)
        backdrop.frame = window.bounds
        backdrop.alpha = 0
        window.addSubview(backdrop)
        
        let toast = createToastView()
        toast.center = CGPoint(x: window.bounds.midX, y: window.bounds.maxY + toast.bounds.height)
        toast.alpha = 0
        toast.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        window.addSubview(toast)
        
        // Animate in
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            backdrop.effect = UIBlurEffect(style: .systemUltraThinMaterial)
            backdrop.alpha = 0.55
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.6, options: .curveEaseOut) {
            toast.center = CGPoint(x: window.bounds.midX, y: window.bounds.midY)
            toast.alpha = 1
            toast.transform = .identity
        }
        
        // Animate out
        UIView.animate(withDuration: 0.4, delay: 0.9, options: .curveEaseIn) {
            backdrop.effect = nil
            backdrop.alpha = 0
        } completion: { _ in
            backdrop.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.28, delay: 0.9, options: .curveEaseIn) {
            toast.center = CGPoint(x: window.bounds.midX, y: -toast.bounds.height * 4)
            toast.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            toast.alpha = 0
        } completion: { _ in
            toast.removeFromSuperview()
        }
    }
    
    private static func createToastView() -> UIView {
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 44, weight: .medium)
        let iconImage = UIImage(systemName: "sparkles", withConfiguration: iconConfig)
        let iconView = UIImageView(image: iconImage)
        iconView.tintColor = .label
        iconView.layer.shadowColor = UIColor.systemGreen.cgColor
        iconView.layer.shadowRadius = 12
        iconView.layer.shadowOpacity = 0.9
        iconView.layer.shadowOffset = .zero
        iconView.sizeToFit()
        
        let label = UILabel()
        label.text = "Work Mode Enabled"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.layer.shadowColor = UIColor.systemGreen.cgColor
        label.layer.shadowRadius = 8
        label.layer.shadowOpacity = 0.8
        label.layer.shadowOffset = .zero
        label.sizeToFit()
        
        let spacing: CGFloat = 8
        let width = max(iconView.bounds.width, label.bounds.width)
        let height = iconView.bounds.height + spacing + label.bounds.height
        
        let toast = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        toast.backgroundColor = .clear
        
        iconView.center = CGPoint(x: width / 2, y: iconView.bounds.height / 2)
        label.center = CGPoint(x: width / 2, y: iconView.bounds.height + spacing + label.bounds.height / 2)
        
        toast.addSubview(iconView)
        toast.addSubview(label)
        
        return toast
    }
}
