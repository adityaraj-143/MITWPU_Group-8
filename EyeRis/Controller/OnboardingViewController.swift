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
        let placeholderUser = User(
            firstName: "Test",
            lastName: "User",
            gender: "Male",
            dob: Date(),
            eyeHealthData: UserEyeHealthData(
                condition: [.digitalEyeStrain]
            )
        )
        
        // Save to CoreData
        UserStore().save(placeholderUser)
        
        // Update runtime store
        UserDataStore.shared.updateFirstName(placeholderUser.firstName)
        UserDataStore.shared.updateLastName(placeholderUser.lastName)
        UserDataStore.shared.updateGender(placeholderUser.gender)
        UserDataStore.shared.updateDOB(placeholderUser.dob)
        UserDataStore.shared.updateEyeConditions(placeholderUser.eyeHealthData.condition)
        
        // Navigate to Main storyboard as root
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateInitialViewController()!
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = mainVC
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
}
