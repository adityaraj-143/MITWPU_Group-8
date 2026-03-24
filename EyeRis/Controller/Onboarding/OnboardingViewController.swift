//
//  OnboardingViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 04/03/26.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addUser(_ sender: Any) {
        // Update user via UserManager (auto-persists to CoreData)
        UserManager.shared.updateUser(
            firstName: "Test",
            lastName: "User",
            gender: "Male",
            dob: Date(),
            conditions: [.digitalEyeStrain]
        )
        
        // Navigate to Main storyboard as root
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateInitialViewController()!
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = mainVC
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
}
