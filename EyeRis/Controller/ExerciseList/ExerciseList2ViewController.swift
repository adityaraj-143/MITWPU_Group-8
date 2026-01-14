import UIKit

class ExerciseList2ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Temporary Dummy Data
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

        // 🔥 IMPORTANT: Disable auto-sizing
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

    // ONE spacing value used everywhere
    private var spacing: CGFloat { 16 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: spacing,
            left: spacing,
            bottom: spacing,
            right: spacing
        )
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let columns: CGFloat = 2

        let totalHorizontalSpacing =
            (columns + 1) * spacing   // left + middle + right

        let availableWidth =
            collectionView.bounds.width - totalHorizontalSpacing

        let cellWidth = availableWidth / columns

        return CGSize(width: cellWidth, height: 120)
    }
}
