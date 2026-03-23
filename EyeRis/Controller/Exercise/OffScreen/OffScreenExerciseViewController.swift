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
    
    private var isPaused = false
    private var totalStages = 0

    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudioSession()
        setupSounds()
        
        stages = exercise?.getPerformanceInstruction() ?? []
        startNextStage()
        
        totalStages = stages.count

        lightHaptic.prepare()
        mediumHaptic.prepare()
    }
    
    // Configure audio session for playback and mixing
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers, .defaultToSpeaker]
            )
            try session.setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }
    
    // Load audio files and initialize players
    private func setupSounds() {
        guard let tickURL = Bundle.main.url(forResource: "tickkk", withExtension: "mp3"),
              let finalURL = Bundle.main.url(forResource: "finalll", withExtension: "mp3") else {
            return
        }
        
        do {
            tickPlayer = try AVAudioPlayer(contentsOf: tickURL)
            tickPlayer?.prepareToPlay()
            tickPlayer?.volume = 1.0
        } catch {
            print("Tick player error:", error)
        }
        
        do {
            finalPlayer = try AVAudioPlayer(contentsOf: finalURL)
            finalPlayer?.prepareToPlay()
            finalPlayer?.volume = 1.0
        } catch {
            print("Final player error:", error)
        }
    }
    
    // Start next stage in sequence
    private func startNextStage() {
        if currentStageIndex >= stages.count {
            finishExercise()
            return
        }
        
        let stage = stages[currentStageIndex]
        
        let progressText = "Step \(currentStageIndex + 1) of \(totalStages)"
        print(progressText) // replace with label if needed
        
        UIView.transition(with: instructionLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.instructionLabel.text = stage.instruction
        }
        speakInstruction(stage.instruction)
        
        remainingTime = stage.duration
        timerLabel.text = "\(remainingTime)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownTimer?.invalidate()
    }
    
    // Start countdown timer
    private func startTimer() {
        countdownTimer?.invalidate()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, !self.isPaused else { return }
            
            self.remainingTime -= 1
            self.timerLabel.text = "\(self.remainingTime)"
            
            UIView.animate(withDuration: 0.2) {
                self.timerLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.timerLabel.transform = .identity
                }
            }
            
            if (1...3).contains(self.remainingTime) && !self.speechSynth.isSpeaking {
                self.playTick()
                self.lightHaptic.impactOccurred()
            }
            
            if self.remainingTime == 0 {
                self.playFinal()
                self.mediumHaptic.impactOccurred()
            }
            
            if self.remainingTime <= 0 {
                timer.invalidate()
                self.currentStageIndex += 1
                self.startNextStage()
            }
        }
        
        RunLoop.current.add(countdownTimer!, forMode: .common)
    }
    
    // Play tick sound
    private func playTick() {
        guard let player = tickPlayer else { return }
        
        player.stop()
        player.currentTime = 0
        player.prepareToPlay()
        player.play()
    }
    
    // Play final sound
    private func playFinal() {
        guard let player = finalPlayer else { return }
        
        player.stop()
        player.currentTime = 0
        player.prepareToPlay()
        player.play()
    }
    
    // Speak instruction using speech synthesizer
    private func speakInstruction(_ text: String) {
        if speechSynth.isSpeaking {
            speechSynth.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        utterance.postUtteranceDelay = 0.1
        
        speechSynth.speak(utterance)
    }
    
    // Handle completion
    private func finishExercise() {
        exerciseCompleted()
    }
    
    func pauseExercise() {
        countdownTimer?.invalidate()
        isPaused = true
    }

    func resumeExercise() {
        if isPaused {
            isPaused = false
            startTimer()
        }
    }
}
