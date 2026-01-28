import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var profileIconView: UIView!
    
    
    var lastNVA: AcuityTestResult = AcuityTestResultResponse().getLastTestNVA()!
    
    var lastDVA: AcuityTestResult = AcuityTestResultResponse().getLastTestDVA()!
    
    let history = ExerciseHistory()
    
    var lastExercise: ExerciseSummary {
        history.lastExerciseSummary()
        ?? ExerciseSummary(accuracy: 20, speed: 20)
    }
    
    let blinkRateStore = BlinkRateDataStore.shared
    var todayBlinkResult: BlinkRateTestResult?
    
    let recommendedExercises = ExerciseList(user: UserDataStore.shared.currentUser).recommended
    
    let todaysExercise = ExerciseList.shared?.todaysSet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CollectionView.setCollectionViewLayout(generateLayout(), animated: false)
        CollectionView.dataSource = self
        CollectionView.delegate = self
        
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        todayBlinkResult = blinkRateStore.todayResult()
        CollectionView.reloadData()
    }
    
    // MARK: - Register Cells
    private func registerCells() {
        CollectionView.register(UINib(nibName: "GreetingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "greet_cell")
        CollectionView.register(UINib(nibName: "TodayExerciseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "todayExercise_cell")
        CollectionView.register(UINib(nibName: "RecommendedExercisesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "exercises_cell")
        CollectionView.register(UINib(nibName: "TestsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "tests_cell")
        CollectionView.register(UINib(nibName: "BlinkRateCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "blinkRate_cell")
        CollectionView.register(UINib(nibName: "LastExerciseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "lastExercise_cell")
        CollectionView.register(UINib(nibName: "LastTestCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "lastTest_cell")
        CollectionView.register(
            UINib(nibName: "SectionHeaderCollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: "header-kind",
            withReuseIdentifier: "section_header_cell"
        )
    }
    
    @IBAction func chatbotIconTapped(_ sender: Any) {
        self.navigate(to: "ChatBot", with: "ChatbotViewController")
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            navigate(to: "TodaysExerciseSet", with: "TodaysExerciseSetViewController")
            return
        }
        
        if indexPath.section == 2 {
            let exercise = recommendedExercises[indexPath.row]
            
            let storyboard = UIStoryboard(
                name: "exerciseInstruction",
                bundle: nil
            )
            
            let identifier = "ExerciseInstructionViewController"
            let vc = storyboard.instantiateViewController(withIdentifier: identifier)
            
            guard let instructionVC = vc as? (ExerciseInstructionViewController & ExerciseFlowHandling) else {
                assertionFailure("Instruction VC does not conform to ExerciseFlowHandling")
                return
            }
            
            instructionVC.exercise = exercise
            instructionVC.inTodaySet = 0
            instructionVC.source = .home
            
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if indexPath.section == 3 {
            if indexPath.item == 0 {
                // Acuity Test
                navigate(to: "TestInstructions", with: "TestInstructionsViewController", source: .NVALeft)
            } else if indexPath.item == 1 {
                // Blink Rate
                navigate(to: "TestInstructions", with: "TestInstructionsViewController", source: .blinkRateTest)
            }
        }
    }
}


// MARK: - DataSource
extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 7 }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 2: // Recommended Exercises
            return recommendedExercises.count      // 5 cells
        case 3: // Tests
            return 2                      // Always 2 cells
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "greet_cell",
                for: indexPath
            ) as! GreetingCollectionViewCell
            
            cell.onTapNavigation = { [weak self] in
                self?.presentProfilePage()
            }
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "todayExercise_cell",
                for: indexPath
            ) as! TodayExerciseCollectionViewCell
            
            let icons = todaysExercise?.map { $0.exercise.getIcon() } ?? []
            cell.configureLabel(iconImages: icons)
            cell.onTapNavigation = { [weak self] in
                self?.navigate(to: "TodaysExerciseSet", with: "TodaysExerciseSetViewController")
            }
            return cell
            
        case 2: // Recommended Exercises (Horizontal)
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "exercises_cell",
                for: indexPath
            ) as! RecommendedExercisesCollectionViewCell
            let data = recommendedExercises[indexPath.row]
            cell.configure(
                title: data.name,
                subtitle: "204 people did this today",
                icon: data.getIcon(),
                bgColor: data.getBGColor(),
                iconBG: data.getIconBGColor()
            )
            return cell
            
        case 3: // Tests (Horizontal)
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "tests_cell",
                for: indexPath
            ) as! TestsCollectionViewCell
            
            let dueOn = AcuityTestResultResponse.shared.getDueDate()
            
            if(indexPath.item == 0) {
                cell.configure(
                    title: "Acuity Test",
                    subtitle: dueOn,
                    icon: "eyeTest",
                )
            } else {
                cell.configure(
                    title: "Blink Rate ",
                    subtitle: "Check Blinking Rate",
                    icon: "blinkingEye",
                )
            }
            
            return cell
            
        case 4: // Blink Rate
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "blinkRate_cell",
                for: indexPath
            ) as! BlinkRateCollectionViewCell
            
            if let result = todayBlinkResult {
                cell.blinkRateSliderView.value = CGFloat(result.bpm)
                cell.blinkRateSliderView.maxValue = 22
            } else {
                cell.blinkRateSliderView.value = 0
                cell.blinkRateSliderView.maxValue = 22
            }
            
            cell.onTapNavigation = { [weak self] in
                self?.navigate(to: "BlinkRateHistory", with: "BlinkRateHistoryViewController")
            }
            return cell
            
        case 5: // Last Exercise
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "lastExercise_cell",
                for: indexPath
            ) as! LastExerciseCollectionViewCell
            
            cell.onTapNavigation = { [weak self] in
                self?.navigate(to: "ExerciseHistory", with: "ExerciseHistoryViewController")
            }
            
            cell.configure(
                acc: lastExercise.accuracy,
                speed: lastExercise.speed
            )
            return cell
            
        case 6: // Last Test
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "lastTest_cell",
                for: indexPath
            ) as! LastTestCollectionViewCell
            
            cell.onTapNavigation = { [weak self] in
                self?.navigate(to: "TestHistory", with: "TestHistoryViewController")
            }
            
            cell.configure(
                nvaLE: lastNVA.leftEyeScore,
                nvaRE: lastNVA.rightEyeScore,
                dvaLE: lastDVA.leftEyeScore,
                dvaRE: lastDVA.rightEyeScore
            )
            return cell
            
        default:
            fatalError("Unknown section")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "section_header_cell",
            for: indexPath
        ) as! SectionHeaderCollectionReusableView
        
        switch indexPath.section {
        case 2:
            // Recommended Exercises → show NavigateLabel
            header.congfigure(
                headerText: "Exercises for you",
                hideNav: false
            )
            
            header.onTapNavigation = { [weak self] in
                self?.navigate(to: "ExerciseList", with: "ExerciseListViewController")
            }
            
        case 3:
            // Tests → hide NavigateLabel
            header.congfigure(
                headerText: "Tests",
                hideNav: true
            )
            
            header.onTapNavigation = nil
            
        case 4:
            header.congfigure(
                headerText: "Summary",
                hideNav: true
            )
            header.onTapNavigation = nil
            
            
        default:
            header.onTapNavigation = nil
            
            break
        }
        
        return header
    }
    
    
}

