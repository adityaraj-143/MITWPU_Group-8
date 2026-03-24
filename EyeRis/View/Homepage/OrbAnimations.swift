import UIKit

// MARK: - Orb Phase (Work vs Break)

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
    private static let orbAnimationKey = "orbPath"
    private static let trailAnimationKey = "trailProgress"
    
    // MARK: - Orb Creation
    
    static func attachOrb(to view: UIView, phase: OrbPhase = .work) -> UIView {
        let orb = UIView(frame: CGRect(x: 0, y: 0, width: orbSize, height: orbSize))
        orb.layer.cornerRadius = orbSize / 2
        configureOrbAppearance(orb, phase: phase)
        view.addSubview(orb)
        return orb
    }
    
    static func configureOrbAppearance(_ orb: UIView, phase: OrbPhase) {
        let color = phase.color
        orb.backgroundColor = color
        orb.layer.shadowColor = color.cgColor
        orb.layer.shadowRadius = 8
        orb.layer.shadowOpacity = 1
        orb.layer.shadowOffset = .zero
    }
    
    // MARK: - Trail Creation
    
    static func attachTrail(to view: UIView, around card: UIView, phase: OrbPhase = .work) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: card.frame, cornerRadius: card.layer.cornerRadius)
        
        let trail = CAShapeLayer()
        trail.path = path.cgPath
        trail.fillColor = UIColor.clear.cgColor
        trail.lineWidth = 2
        trail.strokeStart = 0
        trail.strokeEnd = 0
        configureTrailAppearance(trail, phase: phase)
        
        view.layer.addSublayer(trail)
        return trail
    }
    
    static func configureTrailAppearance(_ trail: CAShapeLayer, phase: OrbPhase) {
        let color = phase.color.cgColor
        trail.strokeColor = color
        trail.shadowColor = color
        trail.shadowRadius = 6
        trail.shadowOpacity = 0.8
        trail.shadowOffset = .zero
    }
    
    /// Update trail path when card frame changes (rotation, different device)
    static func updateTrailPath(_ trail: CAShapeLayer, around card: UIView) {
        let path = UIBezierPath(roundedRect: card.frame, cornerRadius: card.layer.cornerRadius)
        trail.path = path.cgPath
    }
    
    // MARK: - Orb Animation
    
    static func resetOrb(_ orb: UIView, around card: UIView) {
        orb.layer.removeAnimation(forKey: orbAnimationKey)
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
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        orb.layer.add(animation, forKey: orbAnimationKey)
    }
    
    /// Resume orb at a specific progress point (0.0 to 1.0)
    static func resumeOrbAnimation(_ orb: UIView, around card: UIView, duration: TimeInterval, progress: Double) {
        let path = UIBezierPath(roundedRect: card.frame, cornerRadius: card.layer.cornerRadius)
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = duration
        animation.calculationMode = .paced
        animation.repeatCount = .infinity
        animation.rotationMode = .none
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timeOffset = duration * progress
        
        orb.layer.add(animation, forKey: orbAnimationKey)
    }
    
    static func stopOrbAnimation(_ orb: UIView) {
        orb.layer.removeAnimation(forKey: orbAnimationKey)
    }
    
    // MARK: - Trail Animation
    
    static func resetTrail(_ trail: CAShapeLayer) {
        trail.removeAllAnimations()
        trail.strokeEnd = 0
        trail.strokeStart = 0
    }
    
    static func startTrailAnimation(_ trail: CAShapeLayer, duration: TimeInterval) {
        trail.removeAllAnimations()
        trail.strokeEnd = 0
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        trail.add(animation, forKey: trailAnimationKey)
    }
    
    /// Resume trail at a specific progress point (0.0 to 1.0)
    static func resumeTrailAnimation(_ trail: CAShapeLayer, duration: TimeInterval, progress: Double) {
        trail.removeAllAnimations()
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timeOffset = duration * progress
        
        trail.add(animation, forKey: trailAnimationKey)
    }
    
    static func stopTrailAnimation(_ trail: CAShapeLayer) {
        resetTrail(trail)
    }
    
    // MARK: - Combined Start/Stop
    
    static func startAnimations(
        orb: UIView,
        trail: CAShapeLayer,
        around card: UIView,
        duration: TimeInterval,
        phase: OrbPhase
    ) {
        // Configure appearance
        configureOrbAppearance(orb, phase: phase)
        configureTrailAppearance(trail, phase: phase)
        
        // Reset and start fresh
        resetOrb(orb, around: card)
        resetTrail(trail)
        
        orb.isHidden = false
        trail.isHidden = false
        
        startOrbAnimation(orb, around: card, duration: duration)
        startTrailAnimation(trail, duration: duration)
    }
    
    /// Resume animations at a specific progress point (used for syncing and layout changes)
    static func resumeAnimations(
        orb: UIView,
        trail: CAShapeLayer,
        around card: UIView,
        duration: TimeInterval,
        phase: OrbPhase,
        progress: Double
    ) {
        // Configure appearance
        configureOrbAppearance(orb, phase: phase)
        configureTrailAppearance(trail, phase: phase)
        
        // Stop existing animations
        stopOrbAnimation(orb)
        trail.removeAllAnimations()
        
        // Update trail path to current card frame (handles rotation/resize)
        updateTrailPath(trail, around: card)
        
        orb.isHidden = false
        trail.isHidden = false
        
        // Resume both with same progress using timeOffset
        resumeOrbAnimation(orb, around: card, duration: duration, progress: progress)
        resumeTrailAnimation(trail, duration: duration, progress: progress)
    }
    
    static func stopAnimations(orb: UIView, trail: CAShapeLayer, around card: UIView) {
        stopOrbAnimation(orb)
        resetOrb(orb, around: card)
        stopTrailAnimation(trail)
        trail.isHidden = true
    }
    
    // MARK: - Work Mode Toast
    
    static func showWorkModeEnabledToast(in containerView: UIView, around card: UIView) {
        guard let window = containerView.window else { return }
        
        // Blur backdrop
        let backdrop = UIVisualEffectView(effect: nil)
        backdrop.frame = window.bounds
        backdrop.alpha = 0
        window.addSubview(backdrop)
        
        // Toast content
        let toast = createToastView()
        let startY = window.bounds.maxY + toast.bounds.height
        let landY = window.bounds.midY
        
        toast.center = CGPoint(x: window.bounds.midX, y: startY)
        toast.alpha = 0
        toast.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        window.addSubview(toast)
        
        // Animate in
        animateToastIn(backdrop: backdrop, toast: toast, landY: landY)
        
        // Animate out after delay
        animateToastOut(backdrop: backdrop, toast: toast, delay: 0.9)
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
        let wrapperWidth = max(iconView.bounds.width, label.bounds.width)
        let wrapperHeight = iconView.bounds.height + spacing + label.bounds.height
        
        let toast = UIView(frame: CGRect(x: 0, y: 0, width: wrapperWidth, height: wrapperHeight))
        toast.backgroundColor = .clear
        
        iconView.center = CGPoint(x: wrapperWidth / 2, y: iconView.bounds.height / 2)
        label.center = CGPoint(x: wrapperWidth / 2, y: iconView.bounds.height + spacing + label.bounds.height / 2)
        
        toast.addSubview(iconView)
        toast.addSubview(label)
        
        return toast
    }
    
    private static func animateToastIn(backdrop: UIVisualEffectView, toast: UIView, landY: CGFloat) {
        guard let window = backdrop.superview else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            backdrop.effect = UIBlurEffect(style: .systemUltraThinMaterial)
            backdrop.alpha = 0.55
        }
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1.6,
            options: .curveEaseOut
        ) {
            toast.center = CGPoint(x: window.bounds.midX, y: landY)
            toast.alpha = 1
            toast.transform = .identity
        }
    }
    
    private static func animateToastOut(backdrop: UIVisualEffectView, toast: UIView, delay: Double) {
        guard let window = backdrop.superview else { return }
        
        UIView.animate(withDuration: 0.4, delay: delay, options: .curveEaseIn) {
            backdrop.effect = nil
            backdrop.alpha = 0
        } completion: { _ in
            backdrop.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.28, delay: delay, options: .curveEaseIn) {
            toast.center = CGPoint(x: window.bounds.midX, y: -toast.bounds.height * 4)
            toast.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            toast.alpha = 0
        } completion: { _ in
            toast.removeFromSuperview()
        }
    }
}
