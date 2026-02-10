//
//  TodayExerciseCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class TodayExerciseCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate {
    
    var opt1 = "C3EFC3"
    
    @IBOutlet weak var IconsCollectionView: UICollectionView!
    @IBOutlet weak var mainView: UIView!
    
    var exercises: [Exercise] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.applyCornerRadius()
        IconsCollectionView.dataSource = self
        IconsCollectionView.delegate = self
        
        IconsCollectionView.register(
            UINib(nibName: "TodayExerciseIconCell", bundle: nil),
            forCellWithReuseIdentifier: "IconCell"
        )
        
        if let layout = IconsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = -4
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        }
        
        IconsCollectionView.clipsToBounds = true
        mainView.clipsToBounds = true
    }
    
    var onTapNavigation: (() -> Void)?
    
    @IBAction func navigationButtonTapped(_ sender: Any) {
        onTapNavigation?()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cellHeight: CGFloat = 32
        let collectionHeight = IconsCollectionView.bounds.height
        
        let verticalInset = max(0, (collectionHeight - cellHeight) / 2)
        
        IconsCollectionView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: 0,
            bottom: verticalInset,
            right: 0
        )
    }
    
    func configure(exercises: [Exercise]?) {
        self.exercises = exercises ?? []
        IconsCollectionView.reloadData()
    }
}

extension TodayExerciseCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "IconCell",
            for: indexPath
        ) as! TodayExerciseIconCell
        
        let exercise = exercises[indexPath.item]
        
        let image = UIImage(named: exercise.getIcon())!
        let bgColor = exercise.getIconBGColor()
        
        cell.layer.zPosition = CGFloat(indexPath.item)
        cell.configure(image: image, bgColor: bgColor)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 32, height: 32)
    }
}

