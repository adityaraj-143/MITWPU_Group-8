//
//  TestInstructionsViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

enum TestFlowSource {
    case NVALeft
    case NVARight
    case DVALeft
    case DVARight
    case blinkRateTest
}

class TestInstructionsViewController: UIViewController, UICollectionViewDelegate {
    
    
    @IBOutlet weak var pageControlOutlet: UIPageControl!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var CollectionView: UICollectionView!
    var source: TestFlowSource?
    
    var test: AcuityTest?
    var blinkTest: BlinkRateTest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let source else {
            fatalError("TestInstructionsViewController launched without source")
        }
        
        switch source {
        case .NVALeft:
            test = mockTestNVA
            
        case .DVALeft, .NVARight, .DVARight:
            test = mockTestDVA
            
        case .blinkRateTest:
            blinkTest = BlinkRateTestStore.shared.test
            
        }
        
        registerCell()
        
        CollectionView.dataSource = self
        CollectionView.delegate = self
        CollectionView.showsHorizontalScrollIndicator = false
        CollectionView.collectionViewLayout = generateLayout()
        
        if let test = test {
            instructionLabel.text = test.instruction.description.first
            pageControlOutlet.numberOfPages = test.instruction.description.count
        }
        
        if let blinkTest = blinkTest {
            instructionLabel.text = blinkTest.instructions.description.first
            pageControlOutlet.numberOfPages = blinkTest.instructions.description.count
        }
        
        pageControlOutlet.currentPage = 0
        
        pageControlOutlet.addTarget(
            self,
            action: #selector(pageControlChanged(_:)),
            for: .valueChanged
        )
    }
    
    @IBAction func navToCalibrate(_ sender: Any) {
        navigate(
            to: "TestCalibration",
            with: "CalibrationViewController",
            source: source
        )
    }
    
    
    private func registerCell() {
        CollectionView.register(
            UINib(nibName: "TestInstructionsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "TestInstructionsCollectionViewCell"
        )
    }
}

// MARK: - Collection View Layout
extension TestInstructionsViewController {
    
    func generateLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { section, env in
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.8),   // slightly smaller to show next page peeking
                heightDimension: .fractionalHeight(1.0)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            group.interItemSpacing = .fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.interGroupSpacing = 10
            
            section.visibleItemsInvalidationHandler = { [weak self] items, offset, env in
                guard let self else { return }
                
                let centerX = offset.x + env.container.contentSize.width / 2
                
                if let centeredItem = items.min(by: {
                    abs($0.frame.midX - centerX) < abs($1.frame.midX - centerX)
                }) {
                    
                    let index = centeredItem.indexPath.item
                    
                    // Label update
                    self.instructionLabel.text =
                    self.test?.instruction.description[index] ??
                    self.blinkTest?.instructions.description[index]
                    
                    // PageControl update (animated)
                    if self.pageControlOutlet.currentPage != index {
                        UIView.animate(withDuration: 0.25) {
                            self.pageControlOutlet.currentPage = index
                        }
                    }
                }
            }
            
            return section
        }
        
        return layout
    }
}

// MARK: - DataSource
extension TestInstructionsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let test {
            return test.instruction.description.count
        }
        if let blinkTest {
            return blinkTest.instructions.description.count
        }
        return 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TestInstructionsCollectionViewCell",
            for: indexPath
        ) as! TestInstructionsCollectionViewCell
        
        if let test {
            let img = test.instruction.images[indexPath.item]
            cell.configureCell(image: img)
        }
        
        if let blinkTest {
            let img = blinkTest.instructions.images[indexPath.item]
            cell.configureCell(image: img)
        }
        
        return cell
    }
    
    
    @objc private func pageControlChanged(_ sender: UIPageControl) {
        let index = sender.currentPage
        let indexPath = IndexPath(item: index, section: 0)
        
        CollectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
    }
    
}

extension TestInstructionsViewController {
    func navigate(
        to storyboardName: String,
        with identifier: String,
        source: TestFlowSource? = nil
    ) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
        if let calibrationVC = vc as? CalibrationViewController {
            switch source {
            case .NVALeft:
                // NVA instructions → first calibration → NVA Left eye
                calibrationVC.source = .NVALeft
                
            case .NVARight:
                // After NVA Right instructions, we are moving to DVA
                calibrationVC.source = .DVALeft
                
            case .DVALeft:
                // DVA instructions → first calibration → DVA Left eye
                calibrationVC.source = .DVALeft
                
            case .DVARight:
                // Should never go back to instructions after this
                calibrationVC.source = .DVARight
                
            case .blinkRateTest:
                calibrationVC.source = .blinkRateTest
                
            case nil:
                break
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
