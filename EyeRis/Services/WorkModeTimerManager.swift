import UIKit

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

        let total = Double(UserDefaults.standard.integer(forKey: "workModeMinutes") * 60)

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
}
