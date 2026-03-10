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
    
    let genders = ["Male", "Female", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.progress = 0.33
        
        configureDatePicker()
        configureGenderMenu()
    }
    
    // MARK: - Date Picker Setup
    private func configureDatePicker() {
        dobPicker.datePickerMode = .date
        dobPicker.preferredDatePickerStyle = .compact
        dobPicker.maximumDate = Date()
        
        let calendar = Calendar.current
        dobPicker.minimumDate = calendar.date(byAdding: .year, value: -100, to: Date())
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
        onboardingTempData.firstName = firstNameField.text
        onboardingTempData.lastName = lastNameField.text
        onboardingTempData.dob = dobPicker.date
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "ScreenTimeViewController") as! ScreenTimeViewController
        
        vc.onboardingTempData = onboardingTempData
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
