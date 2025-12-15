import UIKit

final class BlinkRateGraphView: UIView {

    // MARK: - Configuration
    private let maxValue: CGFloat = 30
    private let barWidth: CGFloat = 18
    private let barCornerRadius: CGFloat = 6

    // MARK: - Layers
    private var barLayers: [CAShapeLayer] = []
    private var avgLineLayer: CAShapeLayer?

    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        // Graph is redrawn explicitly via configure()
    }

    // MARK: - Public API
    func configure(week: BlinkWeek) {
        // Clear previous drawing (IMPORTANT for reuse)
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        barLayers.removeAll()
        avgLineLayer = nil

        layoutIfNeeded()

        let values = week.days.map { $0?.bpm ?? 0 }

        let calendar = Calendar.current
        let todayIndex = week.days.firstIndex {
            guard let date = $0?.performedOn else { return false }
            return calendar.isDateInToday(date)
        }

        drawBars(values: values, highlightIndex: todayIndex)
        drawAverageLine(values: values)
    }

    // MARK: - Drawing Bars
    private func drawBars(values: [Int], highlightIndex: Int?) {
        guard values.count == 7 else { return }

        let height = bounds.height
        let spacing = (bounds.width - barWidth * 7) / 8

        for (index, value) in values.enumerated() {

            let barHeight = (CGFloat(value) / maxValue) * height
            let x = spacing + CGFloat(index) * (barWidth + spacing)
            let y = height - barHeight

            let rect = CGRect(
                x: x,
                y: y,
                width: barWidth,
                height: barHeight
            )

            let path = UIBezierPath(
                roundedRect: rect,
                cornerRadius: barCornerRadius
            )

            let barLayer = CAShapeLayer()
            barLayer.path = path.cgPath
            barLayer.fillColor = barColor(for: index, highlightIndex: highlightIndex).cgColor

            // Fade-in animation (subtle)
            barLayer.opacity = 0
            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue = 0
            fade.toValue = 1
            fade.duration = 0.25
            barLayer.add(fade, forKey: nil)
            barLayer.opacity = 1

            layer.addSublayer(barLayer)
            barLayers.append(barLayer)
        }
    }

    // MARK: - Average Line
    private func drawAverageLine(values: [Int]) {
        guard !values.isEmpty else { return }

        let avg = CGFloat(values.reduce(0, +)) / CGFloat(values.count)
        let y = bounds.height - (avg / maxValue) * bounds.height

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: bounds.width, y: y))

        let line = CAShapeLayer()
        line.path = path.cgPath
        line.strokeColor = UIColor.systemGreen.cgColor
        line.lineWidth = 1
        line.lineDashPattern = [4, 4]

        layer.addSublayer(line)
        avgLineLayer = line
    }

    // MARK: - Bar Color
    private func barColor(for index: Int, highlightIndex: Int?) -> UIColor {
        if index == highlightIndex {
            return UIColor.systemBlue
        } else {
            return UIColor.systemBlue.withAlphaComponent(0.4)
        }
    }
}
