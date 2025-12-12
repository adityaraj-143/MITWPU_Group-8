import UIKit

class ExerciseHistoryViewController: UIViewController {

    @IBOutlet weak var weekCollectionView: UICollectionView!

    // You can change how many weeks/pages you want. Each page contains 7 days.
    private let weeksCount: Int = 8
    private let weekDays = ["M", "T", "W", "T", "F", "S", "S"]

    // computed total items
    private var totalItems: Int { weeksCount * weekDays.count }

    override func viewDidLoad() {
        super.viewDidLoad()

        // datasource & delegate
        weekCollectionView.dataSource = self
        weekCollectionView.delegate = self

        // Only horizontal scrolling, no vertical bouncing/scroll indicator
        weekCollectionView.showsHorizontalScrollIndicator = false
        weekCollectionView.showsVerticalScrollIndicator = false
        weekCollectionView.alwaysBounceVertical = false
        weekCollectionView.alwaysBounceHorizontal = true
        weekCollectionView.isDirectionalLockEnabled = true
        weekCollectionView.decelerationRate = .fast

        // We DO want horizontal scrolling enabled
        weekCollectionView.isScrollEnabled = true

        // Use compositional layout (one full-week group per page)
        weekCollectionView.collectionViewLayout = makeWeekLayout()

        // Make sure the scroll view delegate is set (for snapping)
        weekCollectionView.delegate = self
    }

    private func makeWeekLayout() -> UICollectionViewLayout {
        // each item is 1/7th of the group's width
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 7.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // padding inside each item so circles don't touch edges
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        // 7 identical subitems = one week
        let subitems = Array(repeating: item, count: 7)

        // group is full width (one page = one week)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(72) // adjust to match your cell height
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: subitems)

        let section = NSCollectionLayoutSection(group: group)
        // groupPagingCentered keeps pages centered and prevents partial cells
        section.orthogonalScrollingBehavior = .groupPagingCentered

        // Add side padding so first/last don't stick to edges
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 8

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    // Helper: convert item index to page index (0-based)
    private func pageIndex(forItemAt index: Int) -> Int {
        return index / weekDays.count
    }

    // Helper: jump/scroll to a page programmatically
    private func scrollToWeek(page: Int, animated: Bool) {
        guard page >= 0 && page < weeksCount else { return }
        // compute contentOffset.x for page
        let pageWidth = weekCollectionView.bounds.width
        let targetX = CGFloat(page) * pageWidth
        weekCollectionView.setContentOffset(CGPoint(x: targetX, y: 0), animated: animated)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ExerciseHistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue from the passed-in collectionView
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as? WeekDayCollectionViewCell else {
            return UICollectionViewCell()
        }

        // Determine weekday label using modulo within the week
        let dayIndexInWeek = indexPath.item % weekDays.count
        cell.weekDay.text = weekDays[dayIndexInWeek]

        // Make the day circle appear correctly — update corner radius once layout has been applied
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = (cell.contentView.bounds.height / 2.0)

        // (Optional) visually show which page (week) this belongs to — useful for debugging
        // let page = pageIndex(forItemAt: indexPath.item)
        // cell.backgroundColor = (page % 2 == 0) ? .clear : .clear

        return cell
    }

    // Optional: tap behavior - jump to the page containing the tapped day
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let page = pageIndex(forItemAt: indexPath.item)
        scrollToWeek(page: page, animated: true)
    }
}

// MARK: - Snapping + Directional only horizontal
extension ExerciseHistoryViewController: UIScrollViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Ensure we're working with our collection view
        guard scrollView == weekCollectionView else { return }

        // One page width == collectionView width
        let pageWidth = scrollView.bounds.width

        // Current and proposed offsets
        let currentOffsetX = scrollView.contentOffset.x
        var proposedOffsetX = targetContentOffset.pointee.x

        // Calculate current and proposed page indexes (floating)
        let rawProposedPage = proposedOffsetX / pageWidth
        let rawCurrentPage = currentOffsetX / pageWidth

        // The default rounding might advance on small drags. We'll require a minimum drag distance or velocity.
        // Distance threshold (fraction of page) and velocity threshold
        let distanceThreshold: CGFloat = 0.35
        let velocityThreshold: CGFloat = 0.35

        // Compute the final page we should land on
        var finalPage = Int(round(rawProposedPage))

        // If user barely moved (small distance & small velocity), prefer snapping back to current page
        let distanceDragged = proposedOffsetX - currentOffsetX
        if abs(distanceDragged) < pageWidth * distanceThreshold && abs(velocity.x) < velocityThreshold {
            finalPage = Int(round(rawCurrentPage))
        } else {
            // If velocity is strong to the right/left, respect direction
            if velocity.x > velocityThreshold {
                finalPage = Int(floor(rawCurrentPage + 1.0))
            } else if velocity.x < -velocityThreshold {
                finalPage = Int(ceil(rawCurrentPage - 1.0))
            } else {
                finalPage = Int(round(rawProposedPage))
            }
        }

        // clamp within 0...weeksCount-1
        finalPage = max(0, min(finalPage, weeksCount - 1))

        // set the target content offset to the exact page
        let newOffsetX = CGFloat(finalPage) * pageWidth
        targetContentOffset.pointee.x = newOffsetX
    }

    // Prevent vertical scrolling — ensure content offset y stays 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == weekCollectionView else { return }
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
        }
    }
}
