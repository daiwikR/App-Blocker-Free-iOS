import SwiftUI
import Combine
import FamilyControls

@MainActor
final class AppState: ObservableObject {
    // MARK: - Onboarding

    @Published var hasOnboarded: Bool {
        didSet { UserDefaults.standard.set(hasOnboarded, forKey: "hasOnboarded") }
    }

    @Published var isAuthorized = false

    // MARK: - Managers (owned here, shared via environment)

    var strictModeManager: StrictModeManager
    var shieldManager: ShieldManager
    var pomodoroManager: PomodoroManager

    // MARK: - Init

    init() {
        hasOnboarded = UserDefaults.standard.bool(forKey: "hasOnboarded")

        let strict = StrictModeManager()
        let shield = ShieldManager(strictModeManager: strict)
        let pomodoro = PomodoroManager(shieldManager: shield, strictModeManager: strict)

        strictModeManager = strict
        shieldManager = shield
        pomodoroManager = pomodoro
    }

    // MARK: - Authorization

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = true
            hasOnboarded = true
        } catch {
            isAuthorized = false
        }
    }
}
