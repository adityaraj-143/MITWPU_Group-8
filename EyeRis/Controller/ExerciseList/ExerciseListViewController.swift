//
//  exListViewController.swift
//  Eyeris Testing
//
//  Created by SDC-USER on 03/12/25.
//

import UIKit

let exercises: [(title: String,
                 subtitle: String,
                 icon: String,
                 bgColor: UIColor,
                 iconBGColor: UIColor)] = [

    ("Figure 8",
     "Move eyes in a figure-eight motion",
     "Infinity",
     UIColor(hex: "D3F2E8"),
     UIColor(hex: "5BC8A8")),

    ("Light Adaption",
     "Adapt eyes to different light levels",
     "Light_Adaption",
     UIColor(hex: "D9ECFF"),
     UIColor(hex: "6FAEFF")),

    ("Guided Blinking",
     "Controlled blinking exercise",
     "Guided Blinking",
     UIColor(hex: "E9E0F8"),
     UIColor(hex: "A68BEB")),

    ("Smooth Pursuit",
     "Follow moving objects smoothly",
     "Smooth_pursuit",
     UIColor(hex: "FFECC2"),
     UIColor(hex: "F5B942")),

    ("Focus Shifting",
     "Shift focus between near and far objects",
     "Focus_shifting",
     UIColor(hex: "F8D7DC"),
     UIColor(hex: "E66A7A")),

    ("Peripheral Focus",
     "Train peripheral vision awareness",
     "Peripheral focus",
     UIColor(hex: "FFE0CC"),
     UIColor(hex: "FF9C66")),

    ("Saccade Training",
     "Quick eye jumps between points",
     "Saccadic Movement",
     UIColor(hex: "D4F1F4"),
     UIColor(hex: "4DB6C6")),
    
    ("Clock Rotation",
     "Rotate gaze in clock directions",
     "clock",
     UIColor(hex: "E0E6FF"),
     UIColor(hex: "6B7CFF")),
]



private func generateLayout() -> UICollectionViewLayout {

    let cardWidth: CGFloat = 164
    let cardHeight: CGFloat = 120
    let sideInset: CGFloat = 22
    let rowSpacing: CGFloat = 18

    // ITEM (fixed-size card)
    let itemSize = NSCollectionLayoutSize(
        widthDimension: .absolute(cardWidth),
        heightDimension: .absolute(cardHeight)
    )

    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    // GROUP (full-width row)
    let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(cardHeight)
    )

    let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: groupSize,
        subitems: [item, item]
    )

    // 🔥 FLEXIBLE spacing between the two cards
    group.interItemSpacing = .flexible(0)

    // SECTION
    let section = NSCollectionLayoutSection(group: group)

    section.interGroupSpacing = rowSpacing

    // Equal margins from both ends
    section.contentInsets = NSDirectionalEdgeInsets(
        top: rowSpacing,
        leading: sideInset,
        bottom: rowSpacing,
        trailing: sideInset
    )

    return UICollectionViewCompositionalLayout(section: section)
}




class ExerciseListViewController: UIViewController {
    
    @IBOutlet weak var CollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CollectionView.dataSource = self
//           CollectionView.delegate = self
        
        CollectionView.register(UINib(nibName: "ExerciseListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "exercise_cell")
        
        CollectionView.collectionViewLayout = generateLayout()
    }
    
    
}

extension ExerciseListViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return exercises.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "exercise_cell",
            for: indexPath
        ) as! ExerciseListCollectionViewCell

        let exercise = exercises[indexPath.item]

        // 🔥 FIX: Try SF Symbol first, then asset
        let iconImage =
            UIImage(systemName: exercise.icon) ??
            UIImage(named: exercise.icon) ??
            UIImage()

        // Debug safety (remove in Release)
        assert(iconImage.size != .zero, "❌ Missing icon: \(exercise.icon)")

        cell.configure(
            title: exercise.title,
            subtitle: exercise.subtitle,
            icon: iconImage,
            bgColor: exercise.bgColor,
            iconBG: exercise.iconBGColor
        )

        return cell
    }

}
