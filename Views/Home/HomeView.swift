import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var blockList = BlockList()

    @State private var showBlockList = false
    @State private var showSettings = false
    @State private var showChallenge = false
    @State private var showMotivational = false

    private var pomodoro: PomodoroManager { appState.pomodoroManager }
    private var strict: StrictModeManager { appState.strictModeManager }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    phaseLabel
                    Spacer()
                    timerSection
                    Spacer()
                    statsRow
                    Spacer(minLength: 24)
                    controlButtons
                    Spacer(minLength: 32)
                    bottomBar
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showBlockList) {
                BlockListView(blockList: blockList)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showChallenge) {
                StrictModeChallengeView(
                    manager: strict,
                    onUnlocked: { showChallenge = false }
                )
            }
            .fullScreenCover(isPresented: $showMotivational) {
                MotivationalBlockView(
                    pomodoro: pomodoro,
                    onDismiss: { showMotivational = false }
                )
            }
            .onAppear {
                pomodoro.blockList = blockList
            }
        }
    }

    // MARK: - Subviews

    private var phaseLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: pomodoro.phase.icon)
            Text(pomodoro.phase.rawValue)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.top, 20)
    }

    private var timerSection: some View {
        ZStack {
            TimerRingView(
                progress: pomodoro.progress,
                phase: pomodoro.phase,
                lineWidth: 14
            )
            .frame(width: 260, height: 260)

            VStack(spacing: 4) {
                Text(formattedTime)
                    .font(.system(size: 64, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)

                sessionDotsRow
            }
        }
    }

    /// Dots showing work sessions completed in the current cycle.
    private var sessionDotsRow: some View {
        HStack(spacing: 6) {
            ForEach(0..<pomodoro.settings.sessionsUntilLongBreak, id: \.self) { idx in
                Circle()
                    .fill(idx < pomodoro.completedWorkSessions % pomodoro.settings.sessionsUntilLongBreak
                          ? Color.accentColor
                          : Color.white.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 32) {
            statItem(value: "\(pomodoro.todayFocusedMinutes)", label: "min today")
            statItem(value: "\(pomodoro.completedWorkSessions)", label: "sessions")
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 20) {
            // Reset
            CircleButton(icon: "arrow.counterclockwise", size: 50) {
                pomodoro.reset()
            }
            .disabled(pomodoro.isRunning && strict.isEnabled)

            // Start / Pause (primary)
            Button(action: toggleTimer) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent)
                        .frame(width: 80, height: 80)
                    Image(systemName: pomodoro.isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundStyle(.black)
                }
            }

            // Skip
            CircleButton(icon: "forward.fill", size: 50) {
                guard !strict.isEnabled else { return }
                pomodoro.skip()
            }
            .disabled(strict.isEnabled)
        }
    }

    private var bottomBar: some View {
        HStack {
            // Block list
            BottomBarButton(icon: "shield.fill", label: "Blocked") {
                showBlockList = true
            }

            Spacer()

            // Strict mode toggle
            VStack(spacing: 4) {
                Toggle("", isOn: Binding(
                    get: { strict.isEnabled },
                    set: { newVal in
                        if !newVal && pomodoro.isRunning {
                            showChallenge = true
                        } else if newVal {
                            strict.enable()
                        } else {
                            strict.isEnabled = false
                        }
                    }
                ))
                .labelsHidden()
                .tint(AppTheme.accent)
                Text("Strict")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Settings
            BottomBarButton(icon: "gearshape", label: "Settings") {
                showSettings = true
            }
            .disabled(strict.isEnabled && pomodoro.isRunning)
        }
        .padding(.horizontal, 8)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: 6) {
                Image(systemName: strict.isEnabled ? "lock.fill" : "lock.open")
                    .foregroundStyle(strict.isEnabled ? AppTheme.accent : .secondary)
                Text(strict.isEnabled ? "Strict" : "Normal")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(strict.isEnabled ? AppTheme.accent : .secondary)
            }
        }
    }

    // MARK: - Helpers

    private func toggleTimer() {
        if pomodoro.isRunning {
            if strict.isEnabled {
                showChallenge = true
            } else {
                pomodoro.pause()
                appState.shieldManager.forceStopBlocking()
            }
        } else {
            pomodoro.start()
        }
    }

    private var formattedTime: String {
        let m = pomodoro.timeRemaining / 60
        let s = pomodoro.timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Small reusable buttons

private struct CircleButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: size, height: size)
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
    }
}

private struct BottomBarButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Placeholder SettingsView (expand later)

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Work") {
                    DurationPicker(label: "Focus", keyPath: \.workDuration,
                                   manager: appState.pomodoroManager)
                    DurationPicker(label: "Short Break", keyPath: \.shortBreakDuration,
                                   manager: appState.pomodoroManager)
                    DurationPicker(label: "Long Break", keyPath: \.longBreakDuration,
                                   manager: appState.pomodoroManager)
                }
                Section("Auto") {
                    Toggle("Auto-start Breaks", isOn: $appState.pomodoroManager.settings.autoStartBreaks)
                    Toggle("Auto-start Work", isOn: $appState.pomodoroManager.settings.autoStartWork)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct DurationPicker: View {
    let label: String
    let keyPath: WritableKeyPath<PomodoroSettings, Int>
    let manager: PomodoroManager

    private let options = [5, 10, 15, 20, 25, 30, 45, 60].map { $0 * 60 }

    var body: some View {
        Picker(label, selection: Binding(
            get: { manager.settings[keyPath: keyPath] },
            set: { manager.settings[keyPath: keyPath] = $0 }
        )) {
            ForEach(options, id: \.self) { seconds in
                Text("\(seconds / 60) min").tag(seconds)
            }
        }
    }
}
