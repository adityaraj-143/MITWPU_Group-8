import UIKit

struct OnboardingTempData {
    
    var firstName: String?
    var lastName: String?
    var gender: String?
    var dob: Date?
    
    var phoneScreenTime: Int?
    var largeScreenTime: Int?
    
    var conditions: [Conditions] = []
}

class UserDetailsViewController: UIViewController {
    
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var dobPicker: UIDatePicker!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var genderButton: UIButton!
    
    var onboardingTempData = OnboardingTempData()
    
    let genders = ["Other", "Female", "Male"]
    
    private var dobSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.progress = 0.33
        
        configureDatePicker()
        configureGenderMenu()
        
        styleTextField(firstNameField)
        styleTextField(lastNameField)
    }
    
    func styleTextField(_ textField: UITextField) {
        
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        
        textField.backgroundColor = .systemGray6
        
        textField.clipsToBounds = true
    }
    
    // MARK: - Date Picker Setup
    private func configureDatePicker() {
        dobPicker.datePickerMode = .date
        dobPicker.preferredDatePickerStyle = .compact
        dobPicker.maximumDate = Date()
        
        let calendar = Calendar.current
        dobPicker.minimumDate = calendar.date(byAdding: .year, value: -100, to: Date())
        
        dobPicker.addTarget(self, action: #selector(dobChanged), for: .valueChanged)
    }
    
    @objc private func dobChanged() {
        dobSelected = true
    }
    
    
    // MARK: - Gender Menu
    private func configureGenderMenu() {
        
        var actions: [UIAction] = []
        
        for gender in genders {
            
            let action = UIAction(title: gender) { _ in
                self.genderButton.setTitle(gender, for: .normal)
                self.onboardingTempData.gender = gender
            }
            
            actions.append(action)
        }
        
        genderButton.menu = UIMenu(children: actions)
        genderButton.showsMenuAsPrimaryAction = true
    }
    
    
    
    @IBAction func nextTapped(_ sender: UIButton) {
        // Validate required fields
        guard let firstName = firstNameField.text?.trimmingCharacters(in: .whitespaces),
              !firstName.isEmpty else {
            showAlert(message: "Please enter your first name")
            return
        }
        
        guard let lastName = lastNameField.text?.trimmingCharacters(in: .whitespaces),
              !lastName.isEmpty else {
            showAlert(message: "Please enter your last name")
            return
        }
        
        guard let gender = onboardingTempData.gender, !gender.isEmpty else {
            showAlert(message: "Please select your gender")
            return
        }
        
        guard dobSelected else {
            showAlert(message: "Please select your date of birth")
            return
        }
        
        onboardingTempData.firstName = firstName
        onboardingTempData.lastName = lastName
        onboardingTempData.dob = dobPicker.date
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "ScreenTimeViewController") as! ScreenTimeViewController
        
        vc.onboardingTempData = onboardingTempData
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Required Field",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
