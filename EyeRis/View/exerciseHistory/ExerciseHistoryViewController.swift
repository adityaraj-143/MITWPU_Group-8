import UIKit

class ExerciseHistoryViewController: UIViewController {

    @IBOutlet weak var weekCollectionView: UICollectionView!

    // Number of weeks shown (each week = 7 days)
    private let weeksCount: Int = 4
    private let weekDays = ["M", "T", "W", "T", "F", "S", "S"]

    // Total cells = weeks × days
    private let totalItems = 28

    override func viewDidLoad() {
        super.viewDidLoad()
        
        weekCollectionView.register(
            UINib(nibName: "WeekdayCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "dayCell"
        )
        
        weekCollectionView.dataSource = self
        weekCollectionView.delegate = self

        // Horizontal-only scrolling configuration
        weekCollectionView.showsHorizontalScrollIndicator = false
        weekCollectionView.showsVerticalScrollIndicator = false
        weekCollectionView.alwaysBounceVertical = false
        weekCollectionView.alwaysBounceHorizontal = true
        weekCollectionView.isDirectionalLockEnabled = true
        weekCollectionView.decelerationRate = .fast
        weekCollectionView.isScrollEnabled = true

        // Apply compositional layout
        weekCollectionView.collectionViewLayout = makeWeekLayout()
    }
    
    /**
     Scrolls to the last week once the collection view
     has completed its initial layout pass.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let lastWeekFirstItem = (weeksCount - 1) * weekDays.count
        let indexPath = IndexPath(item: lastWeekFirstItem, section: 0)

        DispatchQueue.main.async {
            self.weekCollectionView.scrollToItem(
                at: indexPath,
                at: .left,
                animated: false
            )
        }
    }

    /**
     Creates a horizontally paged layout where
     one full group represents one week (7 days).
     */
    private func makeWeekLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 7.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 8, leading: 8, bottom: 8, trailing: 8
        )

        let subitems = Array(repeating: item, count: 7)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(72)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: subitems
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 20, bottom: 0, trailing: 20
        )
        section.interGroupSpacing = 8

        return UICollectionViewCompositionalLayout(section: section)
    }

    /**
     Converts an item index into its corresponding
     week index (0-based).
     */
    private func pageIndex(forItemAt index: Int) -> Int {
        return index / weekDays.count
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ExerciseHistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return totalItems
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "dayCell",
            for: indexPath
        ) as? WeekdayCollectionViewCell else {
            return UICollectionViewCell()
        }

        let dayIndex = indexPath.item % weekDays.count
        let letter = weekDays[dayIndex]

        // Using the new button-based configuration API
        cell.configureCell(letter: letter, isSelected: false)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let page = pageIndex(forItemAt: indexPath.item)
        let targetIndexPath = IndexPath(
            item: page * weekDays.count,
            section: 0
        )

        collectionView.scrollToItem(
            at: targetIndexPath,
            at: .left,
            animated: true
        )
    }

    /**
     Clamps scrolling to prevent moving beyond
     available weeks.
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let maxX = CGFloat(weeksCount - 1) * pageWidth

        if scrollView.contentOffset.x < 0 {
            scrollView.contentOffset.x = 0
        }

        if scrollView.contentOffset.x > maxX {
            scrollView.contentOffset.x = maxX
        }
    }
}
