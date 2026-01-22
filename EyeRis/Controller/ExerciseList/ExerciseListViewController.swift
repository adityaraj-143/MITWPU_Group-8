//
//  exListViewController.swift
//  Eyeris Testing
//
//  Created by SDC-USER on 03/12/25.
//

import UIKit

class ExerciseListViewController: UIViewController {
    
    let exercises = ExerciseList(user: UserDataStore.shared.currentUser).exercises
    
    @IBOutlet weak var CollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CollectionView.dataSource = self

        
        CollectionView.register(UINib(nibName: "ExerciseListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "exercise_cell")
        
        CollectionView.collectionViewLayout = generateLayout()
    }
    
    
}

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
            title: exercise.name,
            subtitle: exercise.instructions.description,
            icon: exercise.getIcon(),
            bgColor: exercise.getBGColor(),
            iconBG: exercise.getIconBGColor()
        )
        
        return cell
    }
    
}
