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
    
    /// Currently selected conditions (synced with UserManager)
    private var selectedConditions: [Conditions] = []
    
    // MARK: - State
    private var isEditingProfile = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialFieldState()
        setupMenus()
        setupConditionsTapGesture()

        genderButton.showsMenuAsPrimaryAction = true
        eyeSightButton.showsMenuAsPrimaryAction = true

        navigationItem.rightBarButtonItem = editButton
        
        // Load selected conditions from user
        selectedConditions = userManager.currentUser.eyeHealthData.condition

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
    
    // MARK: - Conditions Tap Gesture
    private func setupConditionsTapGesture() {
        conditionsLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(conditionsLabelTapped))
        conditionsLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func conditionsLabelTapped() {
        if isEditingProfile {
            showConditionsSelectionPopup()
        } else {
            showConditionsViewPopup()
        }
    }
    
    // MARK: - View Conditions Popup (Read-only)
    private func showConditionsViewPopup() {
        let conditions = userManager.currentUser.eyeHealthData.condition
        
        let title = "Your Eye Conditions"
        let message: String
        
        if conditions.isEmpty {
            message = "No conditions selected."
        } else {
            message = conditions.map { "• \($0.displayText)" }.joined(separator: "\n")
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Conditions Selection Popup (Edit mode)
    private func showConditionsSelectionPopup() {
        let alert = UIAlertController(
            title: "Select Eye Conditions",
            message: "Tap to toggle selection",
            preferredStyle: .actionSheet
        )
        
        // Add each condition as an action
        for condition in Conditions.allCases {
            let isSelected = selectedConditions.contains(condition)
            let checkmark = isSelected ? "✓ " : "   "
            let title = "\(checkmark)\(condition.displayText)"
            
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.toggleCondition(condition)
                // Re-show the popup to allow multiple selections
                self?.showConditionsSelectionPopup()
            }
            alert.addAction(action)
        }
        
        // Done button
        alert.addAction(UIAlertAction(title: "Done", style: .cancel) { [weak self] _ in
            self?.saveConditions()
        })
        
        // For iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = conditionsLabel
            popoverController.sourceRect = conditionsLabel.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func toggleCondition(_ condition: Conditions) {
        if let index = selectedConditions.firstIndex(of: condition) {
            selectedConditions.remove(at: index)
        } else {
            selectedConditions.append(condition)
        }
    }
    
    private func saveConditions() {
        userManager.updateEyeConditions(selectedConditions)
        updateConditionsLabel()
    }
    
    private func updateConditionsLabel() {
        if selectedConditions.isEmpty {
            conditionsLabel.text = "None"
        } else if selectedConditions.count == 1 {
            conditionsLabel.text = selectedConditions.first?.displayText
        } else {
            conditionsLabel.text = "\(selectedConditions.count) conditions"
        }
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
        updateConditionsLabel()
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
