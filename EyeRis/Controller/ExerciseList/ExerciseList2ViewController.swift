import UIKit

class ExerciseList2ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Dummy Data (temporary)
    private let exercises: [String] = [
        "Figure 8",
        "Light Adaption",
        "Guided Blinking",
        "Smooth Pursuit",
        "Focus Shifting",
        "Peripheral Focus"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Exercises"

            collectionView.delegate = self
            collectionView.dataSource = self

            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.estimatedItemSize = .zero   // 🔥 THIS IS THE FIX
            }
    }
}

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
        ) as? UICollectionViewCell else {
            fatalError("ExerciseCell not found")
        }

        return cell
    }
}


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
