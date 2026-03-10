import Foundation
import Combine

// MARK: - StrictModeManager
//
// Owns the strict-mode flag and the hard-challenge unlock flow.
// All published properties are observed by SwiftUI views directly.

@MainActor
final class StrictModeManager: ObservableObject {

    // MARK: - Published state

    @Published var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "strictModeEnabled") }
    }

    @Published private(set) var challengeString: String = ""
    @Published private(set) var cooldownRemaining: Int = 0   // seconds
    @Published private(set) var lastAttemptFailed: Bool = false

    // MARK: - Private

    private var cooldownTimer: AnyCancellable?
    private static let challengeLength = 40
    private static let cooldownSeconds = 30

    private let challengeAlphabet =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$*"

    // MARK: - Init

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: "strictModeEnabled")
        challengeString = Self.generate(alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$*",
                                        length: Self.challengeLength)
    }

    // MARK: - Public API

    /// Refresh the challenge string (call when presenting the challenge screen).
    func refreshChallenge() {
        challengeString = Self.generate(alphabet: challengeAlphabet, length: Self.challengeLength)
        lastAttemptFailed = false
    }

    /// Returns `true` and disables strict mode if `input` matches exactly.
    @discardableResult
    func attemptUnlock(input: String) -> Bool {
        guard cooldownRemaining == 0 else { return false }

        if input == challengeString {
            isEnabled = false
            lastAttemptFailed = false
            return true
        } else {
            lastAttemptFailed = true
            startCooldown()
            refreshChallenge()
            return false
        }
    }

    /// Enable strict mode (no challenge required to turn ON).
    func enable() {
        isEnabled = true
        refreshChallenge()
    }

    // MARK: - Private helpers

    private func startCooldown() {
        cooldownRemaining = Self.cooldownSeconds
        cooldownTimer?.cancel()
        cooldownTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.cooldownRemaining > 0 {
                    self.cooldownRemaining -= 1
                } else {
                    self.cooldownTimer?.cancel()
                }
            }
    }

    private static func generate(alphabet: String, length: Int) -> String {
        let chars = Array(alphabet)
        return String((0..<length).compactMap { _ in chars.randomElement() })
    }
}
