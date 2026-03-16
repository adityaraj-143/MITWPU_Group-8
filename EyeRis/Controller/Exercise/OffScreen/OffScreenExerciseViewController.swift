enum ExerciseSource {
    case todaysSet
    case recommended
    case list
}

import UIKit
import AVFoundation

class OffScreenExerciseViewController: UIViewController, ExerciseFlowHandling {
    
    var flowMode: ExerciseFlowMode?
    var exercise: Exercise?
    var source: ExerciseSource?
    
    private var stages: [ExerciseStage] = []
    private var currentStageIndex = 0
    private var countdownTimer: Timer?
    private var remainingTime = 0
    
    private let speechSynth = AVSpeechSynthesizer()
    private var tickPlayer: AVAudioPlayer?
    private var finalPlayer: AVAudioPlayer?
    

    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSounds()
        
        stages = exercise?.getPerformanceInstruction() ?? []
        startNextStage()
    }

    private func startNextStage() {
        // Stop if finished
        if currentStageIndex >= stages.count {
            finishExercise()
            return
        }

        let stage = stages[currentStageIndex]

        instructionLabel.text = stage.instruction
        speakInstruction(stage.instruction)

        remainingTime = stage.duration
        timerLabel.text = "\(remainingTime)"

        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownTimer?.invalidate()
    }
    
    private func startTimer() {
        countdownTimer?.invalidate()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            self.remainingTime -= 1
            self.timerLabel.text = "\(self.remainingTime)"

            if self.remainingTime == 3 || self.remainingTime == 2 || self.remainingTime == 1 {
                self.tickPlayer?.play()
            }

            if self.remainingTime == 0 {
                self.finalPlayer?.play()
            }

            if self.remainingTime <= 0 {
                timer.invalidate()
                self.currentStageIndex += 1
                self.startNextStage()
            }
        }
    }
    
    private func finishExercise() {
        exerciseCompleted()
    }
    
    private func speakInstruction(_ text: String) {
        
        if speechSynth.isSpeaking {
            speechSynth.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        speechSynth.speak(utterance)
    }
    
    private func setupSounds() {
        
        let tickURL = Bundle.main.url(forResource: "tick", withExtension: "wav")
        let finalURL = Bundle.main.url(forResource: "final", withExtension: "wav")

        print("Tick URL:", tickURL)
        print("Final URL:", finalURL)

        if let tickURL = tickURL {
            tickPlayer = try? AVAudioPlayer(contentsOf: tickURL)
            tickPlayer?.prepareToPlay()
        }

        if let finalURL = finalURL {
            finalPlayer = try? AVAudioPlayer(contentsOf: finalURL)
            finalPlayer?.prepareToPlay()
        }
    }
}
