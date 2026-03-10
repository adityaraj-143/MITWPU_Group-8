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
        
        guard let list = ExerciseList.shared,
              let firstTodayExercise = list.todaysSet.first?.exercise else {
            assertionFailure("Today's set is empty or not initialized")
            return
        }
        
        let storyboard = UIStoryboard(
            name: firstTodayExercise.type == .onScreen
            ? "ExerciseInstruction"
            : "OffScreenExerciseInstruction",
            bundle: nil
        )
        
        let identifier = firstTodayExercise.type == .onScreen
        ? "ExerciseInstructionViewController"
        : "OffScreenExerciseInstructionViewController"
        
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
        guard var instructionVC = vc as? ExerciseFlowHandling else {
            assertionFailure("Instruction VC does not conform to ExerciseFlowHandling")
            return
        }
        
        instructionVC.exercise = firstTodayExercise
        instructionVC.source = .todaysSet
        instructionVC.flowMode = .set
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToBlinkRateTest() {
        let storyboard = UIStoryboard(
            name: "TestInstructions",
            bundle: nil
        )
        
        let identifier = "TestInstructionsViewController"
        
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
        guard let instructionVC = vc as? TestInstructionsViewController else {
            assertionFailure("Instruction VC does not conform to ExerciseFlowHandling")
            return
        }
        
        instructionVC.source = .todaysSet
        instructionVC.flowMode = .single
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToInstructionForSingleExercise(_ exercise: Exercise) {
        
        let storyboard = UIStoryboard(
            name: exercise.type == .onScreen
            ? "ExerciseInstruction"
            : "OffScreenExerciseInstruction",
            bundle: nil
        )
        
        let identifier = exercise.type == .onScreen
        ? "ExerciseInstructionViewController"
        : "OffScreenExerciseInstructionViewController"
        
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
        guard var instructionVC = vc as? ExerciseFlowHandling else {
            assertionFailure("Instruction VC does not conform to ExerciseFlowHandling")
            return
        }
        
        instructionVC.exercise = exercise
        instructionVC.source = .todaysSet
        instructionVC.flowMode = .single
        
        navigationController?.pushViewController(vc, animated: true)
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
        exercises.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TodaysExerciseSetCollectionViewCell.reuseID,
            for: indexPath
        ) as! TodaysExerciseSetCollectionViewCell
        
        // First 4 → normal exercises
        if indexPath.item < exercises.count {
            
            let item = exercises[indexPath.item]
            cell.configure(with: item)
            
            cell.onTapNavigation = { [weak self] in
                guard let self = self else { return }
                self.navigateToInstructionForSingleExercise(item.exercise)
            }
            
        } else {
            cell.exerciseName.text = "Blink Rate Test"
            cell.durationLabel.text = "120 sec"
            cell.exerciseImpact.text = "Monitor you blinking rate"
            
            cell.exerciseImage.image = UIImage(systemName: "plus.circle")
            cell.checkmark.isHidden = BlinkRateTestResultManager().getTodayResult() == nil
            
            cell.onTapNavigation = { [weak self] in
                guard let self = self else { return }
                self.navigateToBlinkRateTest()
            }
        }
        
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

