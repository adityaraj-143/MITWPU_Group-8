//
//  ProfilePageTableViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class ProfilePageTableViewController: UITableViewController {
    
    private let userManager = UserManager.shared
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var eyeSightButton: UIButton!
    @IBOutlet weak var DOBButton: UIDatePicker!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var notifSwitch: UISwitch!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var conditionsLabel: UILabel!
    
    // MARK: - State
    private var isEditingProfile = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialFieldState()
        setupMenus()

        genderButton.showsMenuAsPrimaryAction = true
        eyeSightButton.showsMenuAsPrimaryAction = true

        navigationItem.rightBarButtonItem = editButton

        populateUI()
        profileImage.makeRounded()
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: - Initial UI State
    private func setupInitialFieldState() {
        firstNameField.isUserInteractionEnabled = false
        lastNameField.isUserInteractionEnabled = false
        
        DOBButton.isUserInteractionEnabled = false

        firstNameField.borderStyle = .none
        lastNameField.borderStyle = .none

        genderButton.isEnabled = false
        eyeSightButton.isEnabled = false
    }

    // MARK: - Menus
    private func setupMenus() {

        // Gender menu
        let male = UIAction(title: "Male") { _ in
            self.genderButton.setTitle("Male", for: .normal)
            self.userManager.updateGender("Male")
        }

        let female = UIAction(title: "Female") { _ in
            self.genderButton.setTitle("Female", for: .normal)
            self.userManager.updateGender("Female")
        }

        let other = UIAction(title: "Other") { _ in
            self.genderButton.setTitle("Other", for: .normal)
            self.userManager.updateGender("Other")
        }

        genderButton.menu = UIMenu(
            title: "",
            options: .displayInline,
            children: [male, female, other]
        )
        genderButton.setTitle("Not Set", for: .normal)

        // Eye sight / conditions menu
        let nearSighted = UIAction(title: "Near-Sighted") { _ in
            self.eyeSightButton.setTitle("Near-Sighted", for: .normal)
            self.userManager.updateEyeConditions([.dryEyes])
            self.conditionsLabel.text = self.userManager.primaryEyeCondition
        }

        let farSighted = UIAction(title: "Far-Sighted") { _ in
            self.eyeSightButton.setTitle("Far-Sighted", for: .normal)
            self.userManager.updateEyeConditions([.dryEyes])
            self.conditionsLabel.text = self.userManager.primaryEyeCondition
        }

        let healthy = UIAction(title: "Healthy") { _ in
            self.eyeSightButton.setTitle("Healthy", for: .normal)
            self.userManager.updateEyeConditions([])
            self.conditionsLabel.text = self.userManager.primaryEyeCondition
        }

        eyeSightButton.menu = UIMenu(
            title: "",
            options: .displayInline,
            children: [nearSighted, farSighted, healthy]
        )
        eyeSightButton.setTitle("Not Set", for: .normal)
    }

    // MARK: - Edit Profile
    @IBAction func didTapEditButton(_ sender: UIBarButtonItem) {
        isEditingProfile.toggle()
        updateEditingUI()
    }

    private func updateEditingUI() {
        if isEditingProfile {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "checkmark"),
                style: .plain,
                target: self,
                action: #selector(didTapEditButton)
            )

            DOBButton.isUserInteractionEnabled = true

            firstNameField.isUserInteractionEnabled = true
            lastNameField.isUserInteractionEnabled = true
            genderButton.isEnabled = true
            eyeSightButton.isEnabled = true

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

            DOBButton.isUserInteractionEnabled = false

            firstNameField.isUserInteractionEnabled = false
            lastNameField.isUserInteractionEnabled = false
            genderButton.isEnabled = false
            eyeSightButton.isEnabled = false

            firstNameField.borderStyle = .none
            lastNameField.borderStyle = .none

            view.endEditing(true)
            saveProfileData()
        }
    }

    // MARK: - Populate UI
    private func populateUI() {
        let user = userManager.currentUser

        firstNameField.text = user.firstName
        lastNameField.text = user.lastName
        genderButton.setTitle(user.gender, for: .normal)

        DOBButton.date = user.dob
        conditionsLabel.text = user.eyeHealthData.primaryConditionText
    }

    // MARK: - Save
    private func saveProfileData() {
        userManager.updateUser(
            firstName: firstNameField.text ?? "",
            lastName: lastNameField.text ?? ""
        )
    }
    
    @IBAction func didTapDateButton(_ sender: UIDatePicker) {
        userManager.updateDOB(sender.date)
    }
    
    // MARK: - Notifications
    @IBAction func didToggleNotifications(_ sender: UISwitch) {
        print(sender.isOn ? "Notifications ON" : "Notifications OFF")
    }
}
