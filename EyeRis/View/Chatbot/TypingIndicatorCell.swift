//
//  TypingIndicatorCell.swift
//  EyeRis
//
//  Created by SDC-USER on 18/03/26.
//

import UIKit

/// A collection view cell that displays the classic 3-dot typing animation
final class TypingIndicatorCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "TypingIndicatorCell"
    
    private enum Layout {
        static let dotSize: CGFloat = 8
        static let dotSpacing: CGFloat = 6
        static let bubblePadding: CGFloat = 16
        static let bubbleVerticalPadding: CGFloat = 14
        static let bubbleCornerRadius: CGFloat = 16
        static let leadingInset: CGFloat = 16
        static let trailingInset: CGFloat = 120
    }
    
    private enum Animation {
        static let duration: TimeInterval = 0.4
        static let delayBetweenDots: TimeInterval = 0.15
        static let bounceHeight: CGFloat = -6
    }
    
    // MARK: - UI Elements
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = Layout.bubbleCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dotsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Layout.dotSpacing
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var dots: [UIView] = []
    
    private var isAnimating = false
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopAnimating()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(dotsStackView)
        
        // Create 3 dots
        for _ in 0..<3 {
            let dot = createDot()
            dots.append(dot)
            dotsStackView.addArrangedSubview(dot)
        }
        
        setupConstraints()
    }
    
    private func createDot() -> UIView {
        let dot = UIView()
        dot.backgroundColor = .systemGray
        dot.layer.cornerRadius = Layout.dotSize / 2
        dot.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: Layout.dotSize),
            dot.heightAnchor.constraint(equalToConstant: Layout.dotSize)
        ])
        
        return dot
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Bubble view constraints (left aligned for incoming message style)
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.leadingInset),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -Layout.trailingInset),
            
            // Dots stack view constraints
            dotsStackView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Layout.bubblePadding),
            dotsStackView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -Layout.bubblePadding),
            dotsStackView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: Layout.bubbleVerticalPadding),
            dotsStackView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -Layout.bubbleVerticalPadding)
        ])
    }
    
    // MARK: - Animation
    
    /// Starts the bouncing dot animation
    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        animateDots()
    }
    
    /// Stops the animation
    func stopAnimating() {
        isAnimating = false
        
        // Reset all dots to original position
        dots.forEach { dot in
            dot.layer.removeAllAnimations()
            dot.transform = .identity
        }
    }
    
    private func animateDots() {
        guard isAnimating else { return }
        
        for (index, dot) in dots.enumerated() {
            let delay = Animation.delayBetweenDots * Double(index)
            
            UIView.animate(
                withDuration: Animation.duration,
                delay: delay,
                options: [.curveEaseInOut],
                animations: {
                    dot.transform = CGAffineTransform(translationX: 0, y: Animation.bounceHeight)
                },
                completion: { [weak self] _ in
                    UIView.animate(
                        withDuration: Animation.duration,
                        delay: 0,
                        options: [.curveEaseInOut],
                        animations: {
                            dot.transform = .identity
                        },
                        completion: { _ in
                            // Restart animation cycle after last dot completes
                            if index == 2 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self?.animateDots()
                                }
                            }
                        }
                    )
                }
            )
        }
    }
    
    // MARK: - Layout
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let autoSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        var frame = layoutAttributes.frame
        frame.size.height = max(ceil(autoSize.height), 44)
        layoutAttributes.frame = frame
        
        return layoutAttributes
    }
}
