//
//  BlinkRateGraphCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit

class BlinkRateGraphCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var weeklyBPM: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var graphView: BlinkRateGraphView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.applyCornerRadius()
    }
    
    
    func configure(with week: BlinkWeek) {
        graphView.configure(week: week)

        let values = week.days.compactMap { $0?.bpm }
        let avg = values.isEmpty ? 0 : values.reduce(0, +) / values.count
        weeklyBPM.text = "\(avg) bpm"

        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"

        let start = formatter.string(from: week.startDate)
        let end = formatter.string(
            from: Calendar.current.date(byAdding: .day, value: 6, to: week.startDate)!
        )

        weekLabel.text = "\(start) – \(end)"
    }

}
