import SwiftUI

// MARK: - TimerRingView
//
// Circular progress ring drawn with two arcs: a track and an animated progress arc.

struct TimerRingView: View {
    let progress: Double          // 0.0 → 1.0
    let phase: PomodoroPhase
    let lineWidth: CGFloat

    private var ringColor: Color {
        switch phase {
        case .work: return .accentColor
        case .shortBreak: return .mint
        case .longBreak: return .teal
        }
    }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)

            // Progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TimerRingView(progress: 0.6, phase: .work, lineWidth: 14)
            .frame(width: 260, height: 260)
    }
}
