


import UIKit

enum TestSource {
    case acuityTest
    case blinkRateTest
}

final class TestCompletionViewController: UIViewController {

    @IBOutlet weak var resultsButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!

    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var successImageView: UIImageView!
    @IBOutlet weak var completionLabel: UILabel!

    var source: TestSource?

    var resultNav = ""
    var resultNavId = ""

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        styleButtons()

        switch source {

        case .acuityTest:
            completionLabel.text = "Acuity Test Completed!"
            resultNav = "TestHistory"
            resultNavId = "TestHistoryViewController"

        case .blinkRateTest:
            completionLabel.text = "Blink Rate Test Completed!"
            resultNav = "BlinkRateHistory"
            resultNavId = "BlinkRateHistoryViewController"

        case .none:
            assertionFailure("Invalid source for TestCompletionViewController")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        CompletionAnimations.playSuccessSound()
        CompletionAnimations.playSuccessHaptic()

        iconContainerView.layer.removeAllAnimations()
        iconContainerView.transform = .identity
        CompletionAnimations.startPulse(iconContainerView)

        view.layoutIfNeeded()

        DispatchQueue.main.async {
            CompletionAnimations.burstParticles(
                in: self.view,
                around: self.successImageView
            )
        }
    }
    // MARK: Buttons

    @IBAction func homeButtonTapped(_ sender: Any) {
        goToHome()
    }

    @IBAction func resultsButtonTapped(_ sender: Any) {

        guard !resultNav.isEmpty else { return }

        let storyboard = UIStoryboard(name: resultNav, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: resultNavId)

        guard let nav = navigationController else { return }
        nav.setViewControllers([nav.viewControllers.first!, vc], animated: true)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        goToHome()
    }

    // MARK: Navigation

    private func goToHome() {
        navigationController?.popToRootViewController(animated: true)
    }

    // MARK: Button Styling

    private func styleButtons() {

        // Primary button
        resultsButton.backgroundColor = .systemBlue
        resultsButton.setTitleColor(.white, for: .normal)
        resultsButton.setTitleColor(.white, for: .highlighted)
        resultsButton.tintColor = .white
        resultsButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        resultsButton.layer.cornerRadius = 18
        resultsButton.clipsToBounds = true

        // Secondary button
        homeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        homeButton.layer.cornerRadius = 18
        homeButton.clipsToBounds = true

        if traitCollection.userInterfaceStyle == .dark {
            resultsButton.backgroundColor = UIColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 1)
            homeButton.backgroundColor = UIColor(white: 0.22, alpha: 1)
            homeButton.setTitleColor(.systemGray2, for: .normal)
        } else {
            resultsButton.backgroundColor = UIColor(red: 0.1, green: 0.4, blue: 0.85, alpha: 1)
            homeButton.backgroundColor = UIColor(white: 0.96, alpha: 1)
            homeButton.setTitleColor(.systemGray3, for: .normal)
        }
    }
}
