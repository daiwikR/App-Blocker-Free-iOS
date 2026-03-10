import SwiftUI

// MARK: - StrictModeChallengeView
//
// Presented as a sheet when the user tries to disable strict mode
// while the timer is running.  The user must type the exact challenge
// string to proceed.

struct StrictModeChallengeView: View {
    @ObservedObject var manager: StrictModeManager
    let onUnlocked: () -> Void

    @State private var input = ""
    @State private var shakeOffset: CGFloat = 0
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 32) {
                header

                challengeBox

                inputSection

                actionButton

                if manager.cooldownRemaining > 0 {
                    cooldownLabel
                }

                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 48)
        }
        .onAppear {
            manager.refreshChallenge()
            focused = true
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.accent)

            Text("Strict Mode Active")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("Type the string below exactly to disable strict mode.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var challengeBox: some View {
        VStack(spacing: 8) {
            Text("Challenge string")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(manager.challengeString)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(AppTheme.accent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.accent.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(AppTheme.accent.opacity(0.25), lineWidth: 1)
                        )
                )
                .textSelection(.enabled)
        }
    }

    private var inputSection: some View {
        VStack(spacing: 8) {
            Text("Your input")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("Type the string here…", text: $input)
                .font(.system(.body, design: .monospaced))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($focused)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    manager.lastAttemptFailed ? Color.red.opacity(0.6) : Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                        )
                )
                .offset(x: shakeOffset)

            if manager.lastAttemptFailed {
                Text("Incorrect — try again")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var actionButton: some View {
        Button(action: attempt) {
            Text("Confirm & Disable Strict Mode")
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(input.isEmpty || manager.cooldownRemaining > 0)
    }

    private var cooldownLabel: some View {
        Label(
            "Wait \(manager.cooldownRemaining)s before next attempt",
            systemImage: "timer"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    // MARK: - Logic

    private func attempt() {
        let success = manager.attemptUnlock(input: input)
        if success {
            onUnlocked()
        } else {
            input = ""
            triggerShake()
        }
    }

    private func triggerShake() {
        withAnimation(.default) { shakeOffset = 10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.default) { shakeOffset = -10 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring) { shakeOffset = 0 }
            }
        }
    }
}
