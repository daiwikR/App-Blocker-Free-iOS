import SwiftUI
import FamilyControls

@main
struct BlockerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if !appState.hasOnboarded {
                OnboardingView()
            } else {
                HomeView()
            }
        }
        .preferredColorScheme(.dark)
    }
}
