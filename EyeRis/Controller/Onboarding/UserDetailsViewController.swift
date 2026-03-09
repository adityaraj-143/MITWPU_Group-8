import UIKit

struct OnboardingTempData {
    
    var firstName: String?
    var lastName: String?
    var gender: String?
    var dob: String?
    
    var phoneScreenTime: Int?
    var largeScreenTime: Int?
    
    var conditions: [Conditions] = []
}

class UserDetailsViewController: UIViewController {

    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var DOBTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    
    var onboardingTempData = OnboardingTempData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        progressView.progress = 0.33
        
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        
        onboardingTempData.firstName = nameTextField.text
        onboardingTempData.gender = genderTextField.text
        onboardingTempData.dob = DOBTextField.text
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: "ScreenTimeViewController") as! ScreenTimeViewController
        vc.onboardingTempData = onboardingTempData
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
