import Foundation
import FamilyControls
import ManagedSettings
import Combine

// MARK: - ShieldManager
//
// Applies and removes Screen Time shields via ManagedSettingsStore.
// Blocking is only possible when the app has FamilyControls authorization.

@MainActor
final class ShieldManager: ObservableObject {

    @Published private(set) var isBlocking = false

    private let store = ManagedSettingsStore()
    private let strictModeManager: StrictModeManager

    init(strictModeManager: StrictModeManager) {
        self.strictModeManager = strictModeManager
    }

    // MARK: - Public API

    /// Apply shields for the given FamilyActivitySelection.
    func startBlocking(selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty
            ? nil
            : selection.applicationTokens

        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)

        // Web content filtering for domains lives in webContent.blockedByFilter.
        // For MVP we shield at the app level; domain blocking requires
        // a ContentFilterExtension which is wired up in docs/SETUP.md.

        isBlocking = true
    }

    /// Remove all shields.
    /// Blocked by strict mode while the Pomodoro timer is running.
    func stopBlocking() {
        guard !strictModeManager.isEnabled else {
            // Caller should present StrictModeChallengeView instead.
            return
        }
        clearShields()
    }

    /// Force-remove shields after the timer finishes (bypasses strict mode).
    func forceStopBlocking() {
        clearShields()
    }

    // MARK: - Private

    private func clearShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        isBlocking = false
    }
}
