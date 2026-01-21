//
//  TodayExerciseCollectionViewCell.swift
//  EyeRis
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class TodayExerciseCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate {


    @IBOutlet weak var mainLabel: UIButton!
    @IBOutlet weak var extraCountLabel: UILabel!
    @IBOutlet weak var IconsCollectionView: UICollectionView!
    @IBOutlet weak var mainView: UIView!
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
            layout.minimumLineSpacing = -8  
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        }
        
        IconsCollectionView.clipsToBounds = true
        mainView.clipsToBounds = true
        contentView.clipsToBounds = true

    }

    @IBAction func playButtonAction(_ sender: Any) {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cellHeight: CGFloat = 36
        let collectionHeight = IconsCollectionView.bounds.height
        
        let verticalInset = max(0, (collectionHeight - cellHeight) / 2)
        
        IconsCollectionView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: 0,
            bottom: verticalInset,
            right: 0
        )
    }
    
    func configureLabel(iconImages: [UIImage]) {
        self.icons = iconImages
        IconsCollectionView.reloadData()

        if iconImages.count > 3 {
            extraCountLabel.text = "+\(iconImages.count - 3)"
            extraCountLabel.isHidden = false
        } else {
            extraCountLabel.text = ""
            extraCountLabel.isHidden = true
        }
    }
    
    var icons: [UIImage] = []
}

extension TodayExerciseCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(icons.count, 3)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "IconCell",
            for: indexPath
        ) as! TodayExerciseIconCell

        cell.layer.zPosition = CGFloat(indexPath.item)
        cell.configure(image: icons[indexPath.item])

        return cell
    }


    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 36, height: 36)
    }
}
