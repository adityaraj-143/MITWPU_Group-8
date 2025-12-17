//
//  ProfilePageTableViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class ProfilePageTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var eyeSightButton: UIButton!
    @IBOutlet weak var DOBButton: UIButton!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var notifSwitch: UISwitch!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // MARK: - State
    private var isEditingProfile = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialFieldState()
        setupMenus()
        
        genderButton.showsMenuAsPrimaryAction = true
        eyeSightButton.showsMenuAsPrimaryAction = true
        
        profileImage.makeRounded()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    // MARK: - Initial State
    private func setupInitialFieldState() {
        lastNameField.isUserInteractionEnabled = false
        firstNameField.isUserInteractionEnabled = false
        
        lastNameField.borderStyle = .none
        firstNameField.borderStyle = .none
    }
    
    // MARK: - Menus
    private func setupMenus() {

        // ---------- Gender ----------
        let male = UIAction(title: "Male") { _ in
            self.genderButton.setTitle("Male", for: .normal)
        }

        let female = UIAction(title: "Female") { _ in
            self.genderButton.setTitle("Female", for: .normal)
        }

        let other = UIAction(title: "Other") { _ in
            self.genderButton.setTitle("Other", for: .normal)
        }

        genderButton.menu = UIMenu(
            title: "",
            options: .displayInline,
            children: [male, female, other]
        )

        // ✅ DEFAULT VALUE
        genderButton.setTitle("Not Set", for: .normal)


        // ---------- Eye Sight ----------
        let nearSighted = UIAction(title: "Near-Sighted") { _ in
            self.eyeSightButton.setTitle("Near-Sighted", for: .normal)
        }

        let farSighted = UIAction(title: "Far-Sighted") { _ in
            self.eyeSightButton.setTitle("Far-Sighted", for: .normal)
        }

        let healthy = UIAction(title: "Healthy") { _ in
            self.eyeSightButton.setTitle("Healthy", for: .normal)
        }

        eyeSightButton.menu = UIMenu(
            title: "",
            options: .displayInline,
            children: [nearSighted, farSighted, healthy]
        )

        // ✅ DEFAULT VALUE
        eyeSightButton.setTitle("Not Set", for: .normal)
    }

    
    // MARK: - Edit Profile
    @IBAction func didTapEditButton(_ sender: UIBarButtonItem) {
        isEditingProfile.toggle()
        //          updateEditingState()
        updateEditingUI()
    }
    
   
    private func saveProfileData() {
        let firstName = firstNameField.text ?? ""
        let lastName = lastNameField.text ?? ""
        
        print("Saved: \(firstName) \(lastName)")
        // API / DB / UserDefaults later
    }
    
    
    private func updateEditingUI() {
        if isEditingProfile {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "checkmark"),
                style: .plain,
                target: self,
                action: #selector(didTapEditButton)
            )

            firstNameField.isUserInteractionEnabled = true
            lastNameField.isUserInteractionEnabled = true

            firstNameField.borderStyle = .roundedRect
            lastNameField.borderStyle = .roundedRect

            firstNameField.becomeFirstResponder()
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: .plain,
                target: self,
                action: #selector(didTapEditButton)
            )

            firstNameField.isUserInteractionEnabled = false
            lastNameField.isUserInteractionEnabled = false

            firstNameField.borderStyle = .none
            lastNameField.borderStyle = .none

            view.endEditing(true)
            saveProfileData()
        }
    }


    
    // MARK: - Date of Birth
    @IBAction func didTapDateButton(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        
        let selectedDate = formatter.string(from: sender.date)
        print("DOB selected:", selectedDate)
    }
    
    // MARK: - Notifications
    @IBAction func didToggleNotifications(_ sender: UISwitch) {
        print(sender.isOn ? "Notifications ON" : "Notifications OFF")
    }
}
