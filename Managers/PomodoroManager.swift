import Foundation
import Combine
import UIKit

// MARK: - PomodoroManager
//
// Drives the Pomodoro timer loop.
// Starts / stops blocking via ShieldManager when sessions change.

@MainActor
final class PomodoroManager: ObservableObject {

    // MARK: - Published state

    @Published private(set) var phase: PomodoroPhase = .work
    @Published private(set) var timeRemaining: Int
    @Published private(set) var isRunning = false
    @Published private(set) var completedWorkSessions = 0
    @Published private(set) var todayFocusedSeconds = 0
    @Published var settings: PomodoroSettings

    // The block list that shields will be applied to.
    var blockList: BlockList?

    // MARK: - Private

    private var timerCancellable: AnyCancellable?
    private var sessionStartDate: Date?
    private let shieldManager: ShieldManager
    private let strictModeManager: StrictModeManager
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    // MARK: - Init

    init(shieldManager: ShieldManager, strictModeManager: StrictModeManager) {
        self.shieldManager = shieldManager
        self.strictModeManager = strictModeManager
        let s = PomodoroSettings.load()
        settings = s
        timeRemaining = s.workDuration
        loadTodayStats()
    }

    // MARK: - Public controls

    func start() {
        guard !isRunning else { return }
        isRunning = true
        sessionStartDate = Date()
        applyShields()
        beginBackgroundTask()
        scheduleTimer()
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        timerCancellable?.cancel()
        endBackgroundTask()
    }

    func resume() {
        guard !isRunning else { return }
        start()
    }

    func skip() {
        completeSession(forcedSkip: true)
    }

    func reset() {
        pause()
        timeRemaining = currentPhaseDuration
        sessionStartDate = nil
    }

    func resetAll() {
        pause()
        phase = .work
        completedWorkSessions = 0
        timeRemaining = settings.workDuration
        sessionStartDate = nil
    }

    // MARK: - Computed helpers

    var progress: Double {
        let total = Double(currentPhaseDuration)
        let remaining = Double(timeRemaining)
        guard total > 0 else { return 0 }
        return 1.0 - (remaining / total)
    }

    var todayFocusedMinutes: Int { todayFocusedSeconds / 60 }

    // MARK: - Private timer

    private func scheduleTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard isRunning else { return }
        if phase == .work { todayFocusedSeconds += 1 }
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            completeSession(forcedSkip: false)
        }
    }

    private func completeSession(forcedSkip: Bool) {
        timerCancellable?.cancel()
        isRunning = false
        endBackgroundTask()

        if phase == .work {
            completedWorkSessions += 1
            saveTodayStats()

            // Determine next phase
            if completedWorkSessions % settings.sessionsUntilLongBreak == 0 {
                transition(to: .longBreak)
            } else {
                transition(to: .shortBreak)
            }
            shieldManager.forceStopBlocking()
        } else {
            transition(to: .work)
            if settings.autoStartWork { start() }
        }
    }

    private func transition(to newPhase: PomodoroPhase) {
        phase = newPhase
        timeRemaining = currentPhaseDuration
        sessionStartDate = nil

        if newPhase == .shortBreak || newPhase == .longBreak {
            if settings.autoStartBreaks { start() }
        }
    }

    private var currentPhaseDuration: Int {
        switch phase {
        case .work: return settings.workDuration
        case .shortBreak: return settings.shortBreakDuration
        case .longBreak: return settings.longBreakDuration
        }
    }

    // MARK: - Shields

    private func applyShields() {
        guard phase == .work, let blockList, !blockList.isEmpty else { return }
        shieldManager.startBlocking(selection: blockList.selection)
    }

    // MARK: - Background task (keeps timer alive ~30 s when app backgrounds)

    private func beginBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }

    // MARK: - Persistence (today's stats)

    private let statsKey = "pomodoroTodayStats"

    private func saveTodayStats() {
        let data: [String: Any] = [
            "date": Calendar.current.startOfDay(for: Date()).timeIntervalSince1970,
            "seconds": todayFocusedSeconds
        ]
        UserDefaults.standard.set(data, forKey: statsKey)
    }

    private func loadTodayStats() {
        guard let data = UserDefaults.standard.dictionary(forKey: statsKey),
              let savedInterval = data["date"] as? TimeInterval,
              let seconds = data["seconds"] as? Int else { return }

        let savedDate = Date(timeIntervalSince1970: savedInterval)
        if Calendar.current.isDateInToday(savedDate) {
            todayFocusedSeconds = seconds
        }
    }
}
