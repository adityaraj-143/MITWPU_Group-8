import UIKit

final class BlinkTooltipView: UIView {

    private let valueLabel = UILabel()
    private let dateLabel = UILabel()
    private(set) var isConfigured = false

    func configure() {
        backgroundColor = .systemBlue
        layer.cornerRadius = 18
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        isUserInteractionEnabled = false

        valueLabel.font = .boldSystemFont(ofSize: 20)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center

        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .white.withAlphaComponent(0.9)
        dateLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [valueLabel, dateLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2

        addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8

        isConfigured = true
    }

    func show(for index: Int, week: BlinkWeek, barFrame: CGRect, offset: CGFloat) {
        guard let result = week.days[index] else { return }

        valueLabel.text = "\(result.bpm) bpm"

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        dateLabel.text = formatter.string(from: result.performedOn)

        let tooltipWidth: CGFloat = 140
        let tooltipHeight: CGFloat = 56

        let topPadding: CGFloat = 12   // minimal distance from top
        let idealY = barFrame.minY - offset

        // If idealY is too high, place tooltip just above the bar with small spacing
        let finalY: CGFloat
        if idealY < topPadding {
            finalY = barFrame.minY - tooltipHeight - 12
        } else {
            finalY = idealY
        }

        frame = CGRect(
            x: barFrame.midX - tooltipWidth / 2,
            y: finalY,
            width: tooltipWidth,
            height: tooltipHeight
        )

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    func hide() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseIn, .allowUserInteraction]
        ) {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
}
