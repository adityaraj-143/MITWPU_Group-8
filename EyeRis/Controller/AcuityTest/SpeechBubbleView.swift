//
//  SpeechBubbleView.swift
//  EyeRis
//
//  Created by SDC-USER on 23/01/26.
//


import UIKit

class SpeechBubbleView: UIView {

    private let text: String
    private let shapeLayer = CAShapeLayer()

    init(text: String) {
        self.text = text
        super.init(frame: .zero)
        backgroundColor = .clear
        setupLabel()
        setupShapeLayer()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupLabel() {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    private func setupShapeLayer() {
        layer.insertSublayer(shapeLayer, at: 0)

        shapeLayer.fillColor = UIColor.systemBlue.cgColor

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 3)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        shapeLayer.path = bubblePath().cgPath
    }

    private func bubblePath() -> UIBezierPath {
        let radius: CGFloat = 14
        let arrowHeight: CGFloat = 10
        let arrowWidth: CGFloat = 16

        let bubbleRect = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: bounds.height - arrowHeight
        )

        let path = UIBezierPath(
            roundedRect: bubbleRect,
            cornerRadius: radius
        )

        // Arrow (bottom center)
        let arrowX = bounds.midX
        path.move(to: CGPoint(x: arrowX - arrowWidth/2, y: bubbleRect.maxY))
        path.addLine(to: CGPoint(x: arrowX, y: bubbleRect.maxY + arrowHeight))
        path.addLine(to: CGPoint(x: arrowX + arrowWidth/2, y: bubbleRect.maxY))
        path.close()

        return path
    }
}
