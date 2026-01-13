import UIKit

class ExerciseList2ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Temporary Dummy Data
    // (We will replace this with a real model later)
    private let exercises = [
        (title: "Figure 8",
         subtitle: "Move eyes in a figure-eight motion",
         duration: "1 min",
         icon: "circle"),

        (title: "Light Adaption",
         subtitle: "Adapt eyes to different light levels",
         duration: "1 min",
         icon: "sun.max"),

        (title: "Guided Blinking",
         subtitle: "Controlled blinking exercise",
         duration: "1 min",
         icon: "eye"),

        (title: "Smooth Pursuit",
         subtitle: "Follow moving objects smoothly",
         duration: "1 min",
         icon: "arrow.right.circle"),

        (title: "Focus Shifting",
         subtitle: "Shift focus between near and far",
         duration: "1 min",
         icon: "scope"),

        (title: "Peripheral Focus",
         subtitle: "Train peripheral vision awareness",
         duration: "1 min",
         icon: "viewfinder")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Exercises"

        collectionView.delegate = self
        collectionView.dataSource = self
        


        // 🔥 IMPORTANT: Disable automatic sizing
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ExerciseList2ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return exercises.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ExerciseCell",
            for: indexPath
        ) as? ExerciseCell else {
            fatalError("ExerciseCell not found or class not set")
        }

        let exercise = exercises[indexPath.item]

        // ✅ Part 3: Bind data to cell
        cell.configure(
            title: exercise.title,
            subtitle: exercise.subtitle,
            duration: exercise.duration,
            iconName: exercise.icon
        )

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ExerciseList2ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let horizontalPadding: CGFloat = 16 * 2
        let interItemSpacing: CGFloat = 12

        let availableWidth =
            collectionView.bounds.width
            - horizontalPadding
            - interItemSpacing

        let cellWidth = availableWidth / 2

        return CGSize(width: cellWidth, height: 160)
    }
}
