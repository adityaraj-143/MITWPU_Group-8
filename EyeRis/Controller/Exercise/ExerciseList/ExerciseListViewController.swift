//
//  exListViewController.swift
//  Eyeris Testing
//
//  Created by SDC-USER on 03/12/25.
//

import UIKit

class ExerciseListViewController: UIViewController {
    
    let exercises = ExerciseList(user: UserDataStore.shared.currentUser).exercises
    private var filteredExercises: [Exercise] = []
    @IBOutlet weak var exerciseSegmentController: UISegmentedControl!
    
    @IBOutlet weak var CollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredExercises = exercises.filter { $0.type == .offScreen }
        exerciseSegmentController.selectedSegmentIndex = 0
        
        CollectionView.dataSource = self
        CollectionView.delegate = self
        
        CollectionView.register(UINib(nibName: "ExerciseListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "exercise_cell")
        
        CollectionView.collectionViewLayout = generateLayout()
    }
    
    @IBAction func segmentControllerTapped(_ sender: UISegmentedControl) {
        let selectedType: ExerciseType = sender.selectedSegmentIndex == 0 ? .offScreen : .onScreen
        filteredExercises = exercises.filter { $0.type == selectedType }
        
        CollectionView.reloadData()
    }
    
    private func navigateToInstruction(exercise: Exercise) {

        let storyboardName = exercise.type == .onScreen
            ? "ExerciseInstruction"
            : "OffScreenExerciseInstruction"

        let identifier = exercise.type == .onScreen
            ? "ExerciseInstructionViewController"
            : "OffScreenExerciseInstructionViewController"

        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)

        guard var instructionVC = vc as? ExerciseFlowHandling else {
            assertionFailure("Instruction VC does not conform to ExerciseFlowHandling")
            return
        }

        instructionVC.exercise = exercise
        instructionVC.source = .list

        navigationController?.pushViewController(vc, animated: true)
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
        return filteredExercises.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "exercise_cell",
            for: indexPath
        ) as! ExerciseListCollectionViewCell
        
        let exercise = filteredExercises[indexPath.item]
        
        cell.configure(
            title: exercise.name,
            impact: exercise.getImpact(),
            icon: exercise.getIcon(),
            iconBG: exercise.getIconBGColor()
        )
        return cell
    }
}
extension ExerciseListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let selectedExercise = filteredExercises[indexPath.item]
        navigateToInstruction(exercise: selectedExercise)
    }
}

