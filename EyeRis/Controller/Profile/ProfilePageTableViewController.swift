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
        
        hideKeyboardWhenTappedAround()
        tableView.keyboardDismissMode = .onDrag
        
        genderButton.showsMenuAsPrimaryAction = true
        eyeSightButton.showsMenuAsPrimaryAction = true
        
        navigationItem.rightBarButtonItem = editButton
        
        selectedConditions = userManager.currentUser.eyeHealthData.condition
        
        populateUI()
        profileImage.makeRounded()
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedConditions = userManager.currentUser.eyeHealthData.condition
        updateConditionsLabel()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func didTapEditButton(_ sender: UIBarButtonItem) {
        isEditingProfile.toggle()
        updateEditingUI()
    }

    @IBAction func didTapDateButton(_ sender: UIDatePicker) {
        userManager.updateDOB(sender.date)
    }

    @IBAction func didToggleNotifications(_ sender: UISwitch) {
        print(sender.isOn ? "Notifications ON" : "Notifications OFF")
    }
    
    // MARK: - Conditions Selection (Edit mode)
    private func showConditionsSelectionPopup() {
        performSegue(withIdentifier: "showConditions", sender: nil)
    }
    
    private func saveConditions() {
        userManager.updateEyeConditions(selectedConditions)
        updateConditionsLabel()
    }
    
    // MARK: - Save
    private func saveProfileData() {
        userManager.updateUser(
            firstName: firstNameField.text ?? "",
            lastName: lastNameField.text ?? ""
        )
    }
}

// MARK: - TableView

extension ProfilePageTableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let conditionsIndexPath = IndexPath(row: 0, section: 1)

        guard indexPath == conditionsIndexPath else { return }

        if isEditingProfile {
            performSegue(withIdentifier: "showConditions", sender: nil)
        } else {
            showConditionsViewPopup()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - UI Setup

extension ProfilePageTableViewController {

    func setupInitialFieldState() {
        firstNameField.isUserInteractionEnabled = false
        lastNameField.isUserInteractionEnabled = false
        DOBButton.isUserInteractionEnabled = false

        firstNameField.borderStyle = .none
        lastNameField.borderStyle = .none

        genderButton.isEnabled = false
        eyeSightButton.isEnabled = false
    }
    
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
    

    func updateEditingUI() {
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

    func populateUI() {
        let user = userManager.currentUser

        firstNameField.text = user.firstName
        lastNameField.text = user.lastName
        genderButton.setTitle(user.gender, for: .normal)

        DOBButton.date = user.dob
        updateConditionsLabel()
    }
}

// MARK: - Helpers

extension ProfilePageTableViewController {

    func setupKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        tableView.keyboardDismissMode = .onDrag
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func updateConditionsLabel() {
        let count = selectedConditions.count

        if count == 0 {
            conditionsLabel.text = "None"
        } else if count == 1 {
            conditionsLabel.text = "1 condition"
        } else {
            conditionsLabel.text = "\(count) conditions"
        }
    }

    func showConditionsViewPopup() {
        let conditions = userManager.currentUser.eyeHealthData.condition

        let message = conditions.isEmpty
            ? "No conditions selected."
            : conditions.map { "• \($0.displayText)" }.joined(separator: "\n")

        let alert = UIAlertController(title: "Your Eye Conditions", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
