import SwiftUI

struct OnboardingView: View {
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Deep Focus, by Design",
            body: "Blocker turns your phone into a distraction-free machine using Pomodoro sessions and Screen Time blocking."
        ),
        OnboardingPage(
            icon: "shield.lefthalf.filled",
            title: "Apps & Sites, Blocked",
            body: "Pick the apps and websites that steal your attention. They disappear the moment your focus session begins."
        ),
        OnboardingPage(
            icon: "lock.fill",
            title: "Strict Mode",
            body: "Enable Strict Mode and you can't unlock until the timer finishes — or you type a long random challenge string."
        ),
    ]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { idx in
                        OnboardingPageView(page: pages[idx])
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                pageIndicator

                if page < pages.count - 1 {
                    Button("Next") {
                        withAnimation { page += 1 }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                } else {
                    PermissionsView()
                        .padding(.horizontal, 32)
                        .padding(.bottom, 48)
                }
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { idx in
                Capsule()
                    .fill(idx == page ? AppTheme.accent : Color.white.opacity(0.2))
                    .frame(width: idx == page ? 20 : 8, height: 8)
                    .animation(.spring, value: page)
            }
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Single onboarding slide

private struct OnboardingPage {
    let icon: String
    let title: String
    let body: String
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: page.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(AppTheme.accent)
                .padding(32)
                .background(
                    Circle()
                        .fill(AppTheme.accent.opacity(0.12))
                )

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(page.body)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}
