


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


}
