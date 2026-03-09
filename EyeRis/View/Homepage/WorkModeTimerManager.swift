import UIKit

extension Notification.Name {
    static let workModeTick = Notification.Name("workModeTick")
    static let workModeStateChanged = Notification.Name("workModeStateChanged")
}

final class WorkModeTimerManager {

    static let shared = WorkModeTimerManager()

    private var timer: Timer?
    private var endTime: Date?
    private var isBreak = false
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
        print("Saved minutes:", minutes)

        guard minutes > 0 else { return }
        
        isBreak = false
        endTime = Date().addingTimeInterval(TimeInterval(minutes * 60))

        scheduleTimer()

        NotificationCenter.default.post(name: .workModeStateChanged, object: true)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        endTime = nil

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

            if isBreak {
                start()
            } else {
                startBreak()
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
