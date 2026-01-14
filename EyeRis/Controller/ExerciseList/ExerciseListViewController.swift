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

    // Green
    (
        "Figure 8",
        "Move eyes in a figure-eight motion",
        "circle",
        UIColor(hex: "E6F5EA"),
        UIColor(hex: "C7F3D9")
    ),

    // Blue
    (
        "Light Adaption",
        "Adapt eyes to different light levels",
        "sun.max",
        UIColor(hex: "E7F0FF"),
        UIColor(hex: "CFE0FF")
    ),

    // Pink
    (
        "Guided Blinking",
        "Controlled blinking exercise",
        "eye",
        UIColor(hex: "FCEAF3"),
        UIColor(hex: "F7C7DF")
    ),

    // Yellow
    (
        "Smooth Pursuit",
        "Follow moving objects smoothly",
        "arrow.right",
        UIColor(hex: "FFF5D6"),
        UIColor(hex: "FFE89A")
    ),

    // Red (soft coral)
    (
        "Focus Shifting",
        "Shift focus between near and far objects",
        "scope",
        UIColor(hex: "FDE2E4"),
        UIColor(hex: "F8B9BE")
    ),

    // Orange
    (
        "Peripheral Focus",
        "Train peripheral vision awareness",
        "viewfinder",
        UIColor(hex: "FFE8D6"),
        UIColor(hex: "FFC49A")
    ),

    // Green (alt shade)
    (
        "Eye Relaxation",
        "Reduce eye strain and tension",
        "leaf",
        UIColor(hex: "D9F0E3"),
        UIColor(hex: "B5EFD0")
    ),

    // Blue (alt shade)
    (
        "Near–Far Focus",
        "Alternate focus between distances",
        "arrow.up.left.and.arrow.down.right",
        UIColor(hex: "DCE8FF"),
        UIColor(hex: "BFD6FF")
    )
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

        cell.configure(
            title: exercise.title,
            subtitle: exercise.subtitle,
            icon: UIImage(systemName: exercise.icon) ?? UIImage(),
            bgColor: exercise.bgColor,
            iconBG: exercise.iconBGColor
        )

        return cell
    }
}


//extension ExerciseListViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath
//    ) -> CGSize {
//
//        let padding: CGFloat = 16
//        let spacing: CGFloat = 16
//
//        let totalHorizontalPadding = padding * 2 + spacing
//        let width = (collectionView.bounds.width - totalHorizontalPadding) / 2
//
//        return CGSize(width: width, height: 140)
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        insetForSectionAt section: Int
//    ) -> UIEdgeInsets {
//        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        minimumInteritemSpacingForSectionAt section: Int
//    ) -> CGFloat {
//        16
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        minimumLineSpacingForSectionAt section: Int
//    ) -> CGFloat {
//        16
//    }
//}
//
