//
//  GreetingCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class GreetingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var greetLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        greetLabel.font = .boldSystemFont(ofSize: 28)

    }
    
    var onTapNavigation: (() -> Void)?
    
    func configure(firstName: String) {
        let greeting = getGreeting()
        greetLabel.text = "\(greeting), \(firstName)"
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    @IBAction func profileNav(_ sender: Any) {
        onTapNavigation?()
    }
    
}
