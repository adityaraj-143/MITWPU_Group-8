import UIKit



class ConditionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedConditions: [Int] = []
    
    let options = [
        "Digital Eye Strain",
        "Dry Eye Syndrome",
        "Eye Fatigue",
        "Eye Muscle Tension",
        "Eye Stress",
        "Light Sensitivity",
        "Visual Stress / Contrast Sensitivity",
        "Accommodative Dysfunction",
        "Saccadic Movement Dysfunction",
        "Convergence Insufficiency",
        "Smooth Pursuit Dysfunction",
        "General Eye Coordination",
        "Dry eyes",
        "Eye Strain",
        "Other"
    ]
    
    let question = "Do you experience any of these eye discomforts?"
    
    var onboardingTempData: OnboardingTempData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = 1.0
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 36
        tableView.allowsMultipleSelection = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return question
    }
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        if selectedConditions.contains(indexPath.row) {
            cell.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            cell.imageView?.image = UIImage(systemName: "circle")
        }
        
        cell.tintColor = .systemBlue
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedConditions.contains(indexPath.row) {
            selectedConditions.removeAll { $0 == indexPath.row }
        } else {
            selectedConditions.append(indexPath.row)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func mapIndexToCondition(_ index: Int) -> Conditions? {
        
        switch index {
            
        case 0: return .digitalEyeStrain
        case 1: return .dryEyeSyndrome
        case 2: return .eyeFatigue
        case 3: return .eyeMuscleTension
        case 4: return .eyeStress
        case 5: return .lightSensitivity
        case 6: return .visualStress
        case 7: return .accommodativeDysfunction
        case 8: return .saccadicDysfunction
        case 9: return .convergenceInsufficiency
        case 10: return .smoothPursuitDysfunction
        case 11: return .generalEyeCoordination
        case 12: return .dryEyes
        case 13: return .eyeStrain
            
        default:
            return nil   // "Other"
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        let mappedConditions: [Conditions] = selectedConditions.compactMap {
            mapIndexToCondition($0)
        }
        
        onboardingTempData.conditions = mappedConditions
        
        let store = UserDataStore.shared
        
        if let firstName = onboardingTempData.firstName {
            store.updateFirstName(firstName)
        }
        
        if let lastName = onboardingTempData.lastName {
            store.updateLastName(lastName)
        }
        
        if let gender = onboardingTempData.gender {
            store.updateGender(gender)
        }
        
        if let dob = onboardingTempData.dob {
            store.updateDOB(dob)
        }
        
        store.updateEyeConditions(mappedConditions)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateInitialViewController()!
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = mainVC
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
}


