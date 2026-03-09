import UIKit

class ScreenTimeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var tableView: UITableView!
    
    let questions = [
        "Average phone screen time",
        "Average laptop / PC / TV screen time"
    ]

    let options = [
        "< 1 hour",
        "1–3 hours",
        "3–5 hours",
        "5–7 hours",
        "7+ hours"
    ]
    
    var selectedAnswers: [Int: Int] = [:]
    
    var onboardingTempData: OnboardingTempData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 36
        progressView.progress = 0.66
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return questions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)

        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)

        if selectedAnswers[indexPath.section] == indexPath.row {
            cell.imageView?.image = UIImage(systemName: "largecircle.fill.circle")
        } else {
            cell.imageView?.image = UIImage(systemName: "circle")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView,
    titleForHeaderInSection section: Int) -> String? {

        return questions[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedAnswers[indexPath.section] = indexPath.row

        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)

    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        onboardingTempData.phoneScreenTime = selectedAnswers[0]
        onboardingTempData.largeScreenTime = selectedAnswers[1]
        
        let vc = storyboard.instantiateViewController(withIdentifier: "ConditionsViewController") as! ConditionsViewController
        vc.onboardingTempData = onboardingTempData
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
