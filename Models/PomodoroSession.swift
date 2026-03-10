import Foundation

// MARK: - Phase

enum PomodoroPhase: String, Codable {
    case work = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    var defaultDuration: Int {
        switch self {
        case .work: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        }
    }

    var icon: String {
        switch self {
        case .work: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer"
        case .longBreak: return "figure.walk"
        }
    }
}

// MARK: - Settings

struct PomodoroSettings: Codable {
    var workDuration: Int = 25 * 60
    var shortBreakDuration: Int = 5 * 60
    var longBreakDuration: Int = 15 * 60
    var sessionsUntilLongBreak: Int = 4
    var autoStartBreaks: Bool = false
    var autoStartWork: Bool = false

    static let `default` = PomodoroSettings()

    private static let storageKey = "pomodoroSettings"

    static func load() -> PomodoroSettings {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(PomodoroSettings.self, from: data)
        else { return .default }
        return decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}

// MARK: - Completed Session Record

struct CompletedSession: Codable, Identifiable {
    let id: UUID
    let phase: PomodoroPhase
    let startedAt: Date
    let endedAt: Date
    var focusedMinutes: Int { Int(endedAt.timeIntervalSince(startedAt)) / 60 }
}
