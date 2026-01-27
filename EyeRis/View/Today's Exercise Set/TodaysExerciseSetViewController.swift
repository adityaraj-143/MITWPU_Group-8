    import UIKit

class TodaysExerciseSetViewController: UIViewController {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
        private var exercises: [TodaysExercise] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            exercises = ExerciseList.shared?.todaysSet ?? [];
            setupCollectionView()
            bottomView.applyShadow()
        }
    
    @IBAction func startSetButton(_ sender: Any) {
            
    }
}

    // MARK: - Setup
    extension TodaysExerciseSetViewController {

        private func setupCollectionView() {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = .clear

            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

            layout.estimatedItemSize = .zero
            layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            layout.minimumLineSpacing = 16
        }
    }

    // MARK: - DataSource
    extension TodaysExerciseSetViewController: UICollectionViewDataSource {

        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
            exercises.count
        }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TodaysExerciseSetCollectionViewCell.reuseID,
                for: indexPath
            ) as! TodaysExerciseSetCollectionViewCell

            cell.configure(with: exercises[indexPath.item])
            return cell
        }
    }

    // MARK: - Layout
    extension TodaysExerciseSetViewController: UICollectionViewDelegateFlowLayout {

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {

            let width = collectionView.bounds.width - (16 * 2)
            return CGSize(width: width, height: 180)
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {

            return 20
        }
    }

