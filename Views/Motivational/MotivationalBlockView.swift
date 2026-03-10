import SwiftUI

// MARK: - MotivationalBlockView
//
// Full-screen cover shown when the user tries to access a blocked app
// (app calls this view from the foreground).  Also used as a persistent
// reminder during a session via a notification tap.

struct MotivationalBlockView: View {
    @ObservedObject var pomodoro: PomodoroManager
    let onDismiss: () -> Void

    @State private var quoteIndex = Int.random(in: 0..<Self.quotes.count)

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color(hex: "0D0D0D"), Color(hex: "1A1A2E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                lockIcon

                Spacer().frame(height: 40)

                quoteSection

                Spacer().frame(height: 48)

                statsSection

                Spacer()

                resistButton
                    .padding(.bottom, 48)
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Subviews

    private var lockIcon: some View {
        ZStack {
            Circle()
                .fill(AppTheme.accent.opacity(0.12))
                .frame(width: 120, height: 120)
            Image(systemName: "lock.shield.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .foregroundStyle(AppTheme.accent)
        }
    }

    private var quoteSection: some View {
        VStack(spacing: 16) {
            Text(Self.quotes[quoteIndex].text)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("— \(Self.quotes[quoteIndex].author)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var statsSection: some View {
        VStack(spacing: 20) {
            Divider().opacity(0.15)

            HStack(spacing: 40) {
                statBlock(
                    value: formattedRemaining,
                    label: "remaining"
                )
                statBlock(
                    value: "\(pomodoro.todayFocusedMinutes)",
                    label: "min focused today"
                )
            }

            Divider().opacity(0.15)
        }
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AppTheme.accent)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var resistButton: some View {
        Button(action: onDismiss) {
            Text("Resist the urge →")
                .font(.body.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
        }
    }

    // MARK: - Helpers

    private var formattedRemaining: String {
        let m = pomodoro.timeRemaining / 60
        let s = pomodoro.timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Quotes

    private struct Quote {
        let text: String
        let author: String
    }

    private static let quotes: [Quote] = [
        Quote(text: "The successful warrior is the average person with laser-like focus.", author: "Bruce Lee"),
        Quote(text: "Concentrate all your thoughts upon the work at hand.", author: "Alexander Graham Bell"),
        Quote(text: "It is not that I'm so smart, it's just that I stay with problems longer.", author: "Albert Einstein"),
        Quote(text: "The key is not to prioritize what's on your schedule, but to schedule your priorities.", author: "Stephen Covey"),
        Quote(text: "You don't have to be great to start, but you have to start to be great.", author: "Zig Ziglar"),
        Quote(text: "Deep work is the ability to focus without distraction on a cognitively demanding task.", author: "Cal Newport"),
        Quote(text: "One task at a time. The rest can wait.", author: "Unknown"),
        Quote(text: "Discipline is choosing between what you want now and what you want most.", author: "Abraham Lincoln"),
    ]
}
