//
//  TestResultViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class TestHistoryViewController: UIViewController {
    
    @IBOutlet weak var NVAView: UIView!
    @IBOutlet weak var DVAView: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    // Outlets for this screen
    @IBOutlet weak var nextTest: UIButton!
    @IBOutlet weak var prevTest: UIButton!
    @IBOutlet weak var testDate: UILabel!
    
    // NVA
    @IBOutlet weak var NVAHealthyScore: UILabel!
    @IBOutlet weak var NVALeftEyeScore: UILabel!
    @IBOutlet weak var NVARightEyeScore: UILabel!
    
    
    // DVA
    @IBOutlet weak var DVAHealthyScore: UILabel!
    @IBOutlet weak var DVALeftEyeScore: UILabel!
    @IBOutlet weak var DVARightEyeScore: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    // MARK: - Data for this screen
    
    /// Same results, but grouped so that each item = one date (near + distant together)
    private var groupedResultsByDate: [AcuityTestsForADate] = []
    
    /// Which date (index) we are currently showing on screen
    private var currentIndex: Int = 0
    
    /// Formats Date -> "Apr 25, 2025"
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        groupedResultsByDate = AcuityTestResultManager.shared.groupTestsByDate()
        
        if !groupedResultsByDate.isEmpty {
            currentIndex = groupedResultsByDate.count - 1
        }
        
        updateUIForCurrentDate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [NVAView, DVAView, mainView, commentView].forEach {
            $0?.applyCornerRadius()
        }
        [NVAView, DVAView].forEach {
            $0?.applyShadow()
        }
    }
    
    @IBAction func explainWithEyeris(_ sender: Any) {
        guard !groupedResultsByDate.isEmpty else { return }
        
        let prompt = generateCurrentTestSummaryForAI()
        
        let storyboard = UIStoryboard(name: "ChatBot", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChatbotViewController") as? ChatbotViewController {
            vc.prompt = prompt
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func generateCurrentTestSummaryForAI() -> String {
        
        guard !groupedResultsByDate.isEmpty else {
            return "No test history available."
        }
        
        let testsForDate = groupedResultsByDate[currentIndex]
        
        let dateString = dateFormatter.string(from: testsForDate.date)
        
        let summary = """
        The user completed a visual acuity test on \(dateString).
        
        Distant Vision (DVA):
        - Healthy Benchmark: \(testsForDate.distant.healthyScore)
        - Left Eye Score: \(testsForDate.distant.leftEyeScore)
        - Right Eye Score: \(testsForDate.distant.rightEyeScore)
        
        Near Vision (NVA):
        - Healthy Benchmark: \(testsForDate.near.healthyScore)
        - Left Eye Score: \(testsForDate.near.leftEyeScore)
        - Right Eye Score: \(testsForDate.near.rightEyeScore)
        
        Clinician Comment:
        \(testsForDate.distant.comment)
        
        Please explain these results in simple language and suggest if improvement or professional consultation is recommended.
        """
        
        return summary
    }
    
}

extension TestHistoryViewController{
    
    func updateUIForCurrentDate() {
        
        guard !groupedResultsByDate.isEmpty else {
            
            testDate.text = "--"
            
            NVAHealthyScore.text = "Healthy Score --"
            NVALeftEyeScore.text = "--"
            NVARightEyeScore.text = "--"
            
            DVAHealthyScore.text = "Healthy Score --"
            DVALeftEyeScore.text = "--"
            DVARightEyeScore.text = "--"
            
            prevTest.isEnabled = false
            nextTest.isEnabled = false
            
            prevTest.alpha = 0.3
            nextTest.alpha = 0.3
            
            return
        }
        
        let testsForDate = groupedResultsByDate[currentIndex]
        
        testDate.text = dateFormatter.string(from: testsForDate.date)
        
        DVAHealthyScore.text  = "Healthy Score \(testsForDate.distant.healthyScore)"
        DVALeftEyeScore.text  = testsForDate.distant.leftEyeScore
        DVARightEyeScore.text = testsForDate.distant.rightEyeScore
        
        NVAHealthyScore.text  = "Healthy Score \(testsForDate.near.healthyScore)"
        NVALeftEyeScore.text  = testsForDate.near.leftEyeScore
        NVARightEyeScore.text = testsForDate.near.rightEyeScore
        
        let isFirst = currentIndex == 0
        let isLast  = currentIndex == groupedResultsByDate.count - 1
        
        prevTest.isEnabled = !isFirst
        nextTest.isEnabled = !isLast
        
        prevTest.alpha = prevTest.isEnabled ? 1.0 : 0.3
        nextTest.alpha = nextTest.isEnabled ? 1.0 : 0.3
    }
    @IBAction func prevTestTapped(_ sender: UIButton) {
        guard currentIndex > 0 else { return }
        
        animateButtonTap(sender)
        
        currentIndex -= 1
        animateTransition(direction: .fromLeft)
    }
    
    @IBAction func nextTestTapped(_ sender: UIButton) {
        guard currentIndex < groupedResultsByDate.count - 1 else { return }
        
        animateButtonTap(sender)
        
        currentIndex += 1
        animateTransition(direction: .fromRight)
    }
    
    private func animateTransition(direction: CATransitionSubtype) {
        
        let transition = CATransition()
        transition.type = .push
        transition.subtype = direction
        transition.duration = 0.28
        transition.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        mainView.layer.add(transition, forKey: kCATransition)
        
        updateUIForCurrentDate()
    }
    
    private func animateButtonTap(_ button: UIButton) {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        UIView.animate(withDuration: 0.08,
                       animations: {
            button.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            button.alpha = 0.8
        }) { _ in
            
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 3,
                           options: [.curveEaseOut]) {
                button.transform = .identity
                button.alpha = 1.0
            }
        }
    }
}


