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
    
}
