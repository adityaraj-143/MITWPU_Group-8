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
        
        // 🔥 TEST SOUND (important)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("TEST: Playing tick manually")
            self.tickPlayer?.play()
        }
        
        stages = exercise?.getPerformanceInstruction() ?? []
        startNextStage()
    }
    
    // MARK: - AUDIO SESSION
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .defaultToSpeaker]
            )
            try session.setActive(true)
            
            print("Audio session configured")
        } catch {
            print("Audio session error:", error)
        }
    }
    
    // MARK: - SETUP SOUNDS
    private func setupSounds() {
        
        guard let tickURL = Bundle.main.url(forResource: "tickkk", withExtension: "mp3") else {
            print("❌ Tick file NOT found")
            return
        }
        
        guard let finalURL = Bundle.main.url(forResource: "finalll", withExtension: "mp3") else {
            print("❌ Final file NOT found")
            return
        }
        
        print("✅ Tick URL:", tickURL)
        print("✅ Final URL:", finalURL)
        
        do {
            tickPlayer = try AVAudioPlayer(contentsOf: tickURL)
            tickPlayer?.prepareToPlay()
            tickPlayer?.volume = 1.0
            print("✅ Tick player ready")
        } catch {
            print("❌ Tick player error:", error)
        }
        
        do {
            finalPlayer = try AVAudioPlayer(contentsOf: finalURL)
            finalPlayer?.prepareToPlay()
            finalPlayer?.volume = 1.0
            print("✅ Final player ready")
        } catch {
            print("❌ Final player error:", error)
        }
    }
    
    // MARK: - FLOW
    private func startNextStage() {
        if currentStageIndex >= stages.count {
            finishExercise()
            return
        }
        
        let stage = stages[currentStageIndex]
        
        instructionLabel.text = stage.instruction
        // speakInstruction(stage.instruction)
        
        remainingTime = stage.duration
        timerLabel.text = "\(remainingTime)"
        
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownTimer?.invalidate()
    }
    
    // MARK: - TIMER
    private func startTimer() {
        countdownTimer?.invalidate()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            self.remainingTime -= 1
            self.timerLabel.text = "\(self.remainingTime)"
            
            print("Time:", self.remainingTime)
            
            if (1...3).contains(self.remainingTime) {
                print("🔊 Tick should play")
                self.playTick()
            }
            
            if self.remainingTime == 0 {
                print("🔊 Final should play")
                self.playFinal()
            }
            
            if self.remainingTime <= 0 {
                timer.invalidate()
                self.currentStageIndex += 1
                self.startNextStage()
            }
        }
        
        RunLoop.current.add(countdownTimer!, forMode: .common)
    }
    
    // MARK: - PLAY METHODS
    private func playTick() {
        guard let player = tickPlayer else {
            print("❌ Tick player nil")
            return
        }
        
        player.stop()
        player.currentTime = 0
        player.prepareToPlay()
        player.play()
        
        print("Tick isPlaying:", player.isPlaying)
    }
    
    private func playFinal() {
        guard let player = finalPlayer else {
            print("❌ Final player nil")
            return
        }
        
        player.stop()
        player.currentTime = 0
        player.prepareToPlay()
        player.play()
        
        print("Final isPlaying:", player.isPlaying)
    }
    
    // MARK: - COMPLETE
    private func finishExercise() {
        exerciseCompleted()
    }
}
