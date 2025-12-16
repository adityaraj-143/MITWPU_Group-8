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
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var notifSwitch: UISwitch!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        profileImage.applyCircularMask()
        setupHeaderStyle()
        setupMenus()
        genderButton.showsMenuAsPrimaryAction = true
        eyeSightButton.showsMenuAsPrimaryAction = true
    }

    var isEditingProfile = false

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Note: The 'applyCircularMask' extension isn't shown,
            // but 'setupHeaderStyle' covers the logic needed for circular image.
            // profileImage.applyCircularMask()
            
            setupHeaderStyle()
            setupMenus()
            setupInitialFieldState()
            
            // Ensure buttons show the menu on primary tap
            genderButton.showsMenuAsPrimaryAction = true
            eyeSightButton.showsMenuAsPrimaryAction = true
        }

        // MARK: - Setup
        
        // Sets up the initial read-only state for text fields
        func setupInitialFieldState() {
            firstNameField.isUserInteractionEnabled = false
            lastNameField.isUserInteractionEnabled = false
            
            // Remove borders to make them look like labels initially
            firstNameField.borderStyle = .none
            lastNameField.borderStyle = .none
        }
        
        func setupHeaderStyle() {
            // Makes the profile image circular
            profileImage.layer.cornerRadius = profileImage.frame.height / 2
            profileImage.clipsToBounds = true
        }

        // MARK: - Pull-Down Menus (Gender & Eyesight)
        func setupMenus() {
            // Setup Gender Menu
            let male = UIAction(title: "Male") { _ in self.genderButton.setTitle("Male", for: .normal) }
            let female = UIAction(title: "Female") { _ in self.genderButton.setTitle("Female", for: .normal) }
            let other = UIAction(title: "Other") { _ in self.genderButton.setTitle("Other", for: .normal) }
            
            genderButton.menu = UIMenu(title: "Select Gender", children: [male, female, other])
            
            // Setup Eye Sight Menu
            let perfect = UIAction(title: "20/20") { _ in self.eyeSightButton.setTitle("20/20", for: .normal) }
            let near = UIAction(title: "Near-sighted") { _ in self.eyeSightButton.setTitle("Near-sighted", for: .normal) }
            
            eyeSightButton.menu = UIMenu(title: "Vision", children: [perfect, near])
        }

        // MARK: - Actions
        
        // NEW FUNCTIONALITY: Edit Button Logic
        @IBAction func didTapEditButton(_ sender: UIButton) {
            // Toggle the state
            isEditingProfile.toggle()
            
            if isEditingProfile {
                // STATE: Editing Active (Edit -> Checkmark)
                
                // 1. Change Button to Tick Icon
                editButton.setTitle("", for: .normal)
                editButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                
                // 2. Enable Text Fields
                firstNameField.isUserInteractionEnabled = true
                lastNameField.isUserInteractionEnabled = true
                
                // 3. Add visual border cues
                firstNameField.borderStyle = .roundedRect
                lastNameField.borderStyle = .roundedRect
                
                // 4. Focus on the first name
                firstNameField.becomeFirstResponder()
                
            } else {
                // STATE: Saved / View Only (Checkmark -> Edit)
                
                // 1. Change Button back to "Edit" text
                editButton.setImage(nil, for: .normal)
                editButton.setTitle("Edit", for: .normal)
                
                // 2. Disable Text Fields
                firstNameField.isUserInteractionEnabled = false
                lastNameField.isUserInteractionEnabled = false
                
                // 3. Remove visual border cues
                firstNameField.borderStyle = .none
                lastNameField.borderStyle = .none
                
                // 4. Dismiss Keyboard
                view.endEditing(true)
                
                // --- INSERT SAVE/API CALL LOGIC HERE ---
                print("Profile saved. Name: \(firstNameField.text ?? "") \(lastNameField.text ?? "")")
            }
        }

        // Date of Birth Logic
        @IBAction func didTapDateButton(_ sender: UIButton) {
            let alert = UIAlertController(title: "Select Date", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
            
            let picker = UIDatePicker()
            picker.datePickerMode = .date
            picker.preferredDatePickerStyle = .wheels
            picker.frame = CGRect(x: 0, y: 50, width: alert.view.bounds.width - 20, height: 200)
            
            alert.view.addSubview(picker)
            
            let selectAction = UIAlertAction(title: "Select", style: .default) { _ in
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM yyyy"
                let dateText = formatter.string(from: picker.date)
                self.DOBButton.setTitle(dateText, for: UIControl.State.normal)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(selectAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        }

        // Notification Toggle
        @IBAction func didToggleNotifications(_ sender: UISwitch) {
            if sender.isOn {
                print("Notifications ON")
            } else {
                print("Notifications OFF")
            }
        }
    }

    // NOTE: The 'applyCircularMask' extension was provided in the user's code,
    // so it is included here for completeness, though 'setupHeaderStyle'
    // achieves the same result within this specific view controller.
    extension UIImageView {
        @nonobjc func applyCircularMask() {
            self.layer.cornerRadius = min(self.bounds.width, self.bounds.height) / 2
            self.clipsToBounds = true
        }
    }
