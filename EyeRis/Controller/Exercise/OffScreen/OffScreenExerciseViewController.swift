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
        
        setupAudioSession()
        setupSounds()
        
        stages = exercise?.getPerformanceInstruction() ?? []
        startNextStage()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }
    
    private func setupSounds() {
        guard let tickURL = Bundle.main.url(forResource: "Tick", withExtension: "mp3"),
              let finalURL = Bundle.main.url(forResource: "Final", withExtension: "mp3") else {
            return
        }
        
        tickPlayer = try? AVAudioPlayer(contentsOf: tickURL)
        tickPlayer?.prepareToPlay()
        tickPlayer?.volume = 1.0
        
        finalPlayer = try? AVAudioPlayer(contentsOf: finalURL)
        finalPlayer?.prepareToPlay()
        finalPlayer?.volume = 1.0
    }
    
    private func startNextStage() {
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
            
            // Tick for last 5 seconds
            if (1...5).contains(self.remainingTime) {
                self.playTick()
            }
            
            self.remainingTime -= 1
            self.timerLabel.text = "\(self.remainingTime)"

            if self.remainingTime <= 0 {
                timer.invalidate()
                
                self.playFinal()
                
                // Single haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.currentStageIndex += 1
                    self.startNextStage()
                }
            }
        }
        
        RunLoop.current.add(countdownTimer!, forMode: .common)
    }
    
    private func playTick() {
        tickPlayer?.stop()
        tickPlayer?.currentTime = 0
        tickPlayer?.play()
    }
    
    private func playFinal() {
        finalPlayer?.stop()
        finalPlayer?.currentTime = 0
        finalPlayer?.play()
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
    
    private func finishExercise() {
        exerciseCompleted()
    }
}
