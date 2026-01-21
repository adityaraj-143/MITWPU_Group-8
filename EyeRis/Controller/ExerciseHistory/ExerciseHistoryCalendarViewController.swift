//
//  ExerciseHistoryCalendarViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit

class ExerciseHistoryCalendarViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    @IBAction func clossButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
