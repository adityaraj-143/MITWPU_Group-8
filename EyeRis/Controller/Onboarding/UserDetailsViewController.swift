import UIKit

class UserDetailsViewController: UIViewController {

    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var DOBTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        progressView.progress = 0.33
        
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: "ScreenTimeViewController") as! ScreenTimeViewController

        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
