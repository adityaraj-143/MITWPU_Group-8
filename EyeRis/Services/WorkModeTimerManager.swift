import UIKit
import UserNotifications


extension Notification.Name {
    static let workModeTick = Notification.Name("workModeTick")
    static let workModeStateChanged = Notification.Name("workModeStateChanged")
    static let workModeNotificationSent = Notification.Name("workModeNotificationSent")
    static let workModeBreakStarted = Notification.Name("workModeBreakStarted")
}


final class WorkModeTimerManager {

    static let shared = WorkModeTimerManager()
    private(set) var notificationsSent = 0
    private var timer: Timer?
    private var endTime: Date?
    private(set) var isBreak = false
    var currentRemainingSeconds: Int? {
        guard let endTime else { return nil }
        return Int(ceil(endTime.timeIntervalSinceNow))
    }
    private init() {}

    var isRunning: Bool {
        return timer != nil
    }

    func start() {
        let minutes = UserDefaults.standard.integer(forKey: "workModeMinutes")

        guard minutes > 0 else { return }
        
        isBreak = false
        endTime = Date().addingTimeInterval(TimeInterval(minutes * 60))

        scheduleTimer()

        NotificationCenter.default.post(name: .workModeStateChanged, object: true)

        NotificationCenter.default.post(
            name: .workModeNotificationSent,
            object: notificationsSent
        )
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        endTime = nil

        notificationsSent = 0

        NotificationCenter.default.post(name: .workModeStateChanged, object: false)
    }
    
    func progress() -> Double {
        guard
            let endTime,
            let remaining = currentRemainingSeconds
        else { return 0 }

        // Use correct duration based on current phase
        let total: Double = isBreak ? 20 : Double(UserDefaults.standard.integer(forKey: "workModeMinutes") * 60)

        if total == 0 { return 0 }

        let elapsed = total - Double(remaining)

        return max(0, min(elapsed / total, 1))
    }
    

    private func scheduleTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(tick),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func tick() {

        guard let endTime else { return }

        let secondsLeft = Int(ceil(endTime.timeIntervalSinceNow))

        if secondsLeft <= 0 {

            fireHaptics()
            
            
            if !isBreak {
                notificationsSent += 1
                sendBreakNotification() // 👈 add this
                NotificationCenter.default.post(
                    name: .workModeNotificationSent,
                    object: notificationsSent
                )
            }

            if isBreak {
                start()
            } else {
                startBreak()

                NotificationCenter.default.post(
                    name: .workModeBreakStarted,
                    object: nil
                )
            }

            return
        }

        NotificationCenter.default.post(
            name: .workModeTick,
            object: secondsLeft
        )
    }

    private func startBreak() {
        isBreak = true
        endTime = Date().addingTimeInterval(20)
    }
    

    private func fireHaptics() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    
    private func sendBreakNotification() {
        let content = UNMutableNotificationContent()
        let title = breakTitles.randomElement() ?? "Time for a Break 👀"
        let body = breakBodies.randomElement() ?? "Rest your eyes for a few seconds."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "workMode-break",
            content: content,
            trigger: nil // nil = deliver immediately
        )

        UNUserNotificationCenter.current().add(request)
    }
}

let breakTitles = [
    "Eyes need a breather 👀",
    "Quick eye break time ⏳",
    "Pause and reset your vision ✨",
    "Give your eyes some love ❤️",
    "Tiny break, big relief 🌿",
    "Your eyes called for a break 📢",
    "Relax your focus for a moment 🧘‍♂️",
    "Time to blink and unwind 🌙",
    "Let your eyes recharge ⚡️",
    "A gentle reminder to pause 🌼"
]

let breakBodies = [
    "Look away from the screen for 20 seconds and let your eyes relax.",
    "Focus on something far away and give your eyes a quick reset.",
    "Blink slowly and take a short pause to refresh your vision.",
    "Shift your gaze and allow your eye muscles to loosen up.",
    "Rest your eyes briefly to reduce strain and stay sharp.",
    "Give your screen a break and let your eyes recover naturally.",
    "Take a moment to relax your focus and ease the tension.",
    "Look into the distance and let your eyes reset comfortably.",
    "Pause for a few seconds and let your vision breathe.",
    "Step away mentally and give your eyes a gentle rest."
]
