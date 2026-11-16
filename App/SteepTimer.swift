import SwiftUI
import AudioToolbox
import UserNotifications

enum TimerState: Equatable {
    case idle, running, paused, done
}

@Observable
final class SteepTimer {
    let tea: Tea
    var infusion: Int = 1
    var adjust: Int = 0
    var remaining: Double = 0
    var state: TimerState = .idle

    @ObservationIgnored private var endDate: Date?
    @ObservationIgnored private var ticker: Timer?

    init(tea: Tea) {
        self.tea = tea
        self.remaining = Double(tea.baseSeconds)
    }

    var rawSeconds: Int {
        tea.baseSeconds + (infusion - 1) * tea.increment + adjust
    }

    var total: Int { max(10, rawSeconds) }

    var progress: Double {
        let t = Double(total)
        if t <= 0 { return 0 }
        return min(1, max(0, 1 - remaining / t))
    }

    var isLocked: Bool { state == .running || state == .paused }

    var isLastInfusion: Bool { infusion >= tea.maxInfusions }

    func start() {
        if state == .idle || state == .done {
            remaining = Double(total)
        }
        endDate = Date().addingTimeInterval(remaining)
        state = .running
        scheduleNotification(after: remaining)
        ticker?.invalidate()
        let t = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(t, forMode: .common)
        ticker = t
    }

    func pause() {
        tick()
        guard state == .running else { return }
        stopTicker()
        cancelNotification()
        state = .paused
    }

    func reset() {
        stopTicker()
        cancelNotification()
        state = .idle
        remaining = Double(total)
    }

    func selectInfusion(_ n: Int) {
        guard !isLocked else { return }
        infusion = min(max(1, n), tea.maxInfusions)
        reset()
    }

    func changeAdjust(by delta: Int) {
        guard !isLocked else { return }
        let proposed = rawSeconds + delta
        guard proposed >= 10 else { return }
        adjust += delta
        reset()
    }

    func restartCycle() {
        infusion = 1
        reset()
    }

    private func tick() {
        guard state == .running, let end = endDate else { return }
        let left = end.timeIntervalSinceNow
        if left <= 0 {
            remaining = 0
            stopTicker()
            state = .done
            AudioServicesPlaySystemSound(1007)
        } else {
            remaining = left
        }
    }

    private func stopTicker() {
        ticker?.invalidate()
        ticker = nil
    }

    private func scheduleNotification(after seconds: Double) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        let content = UNMutableNotificationContent()
        content.title = "\(tea.name) is ready"
        content.body = "Infusion \(infusion) has finished steeping."
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "steep.done", content: content, trigger: trigger)
        center.add(request)
    }

    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["steep.done"])
    }
}
