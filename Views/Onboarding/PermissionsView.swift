import SwiftUI

// MARK: - PermissionsView
//
// Shown on the last onboarding slide.
// Requests FamilyControls authorization from the user.

struct PermissionsView: View {
    @EnvironmentObject var appState: AppState
    @State private var isRequesting = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: requestPermission) {
                HStack(spacing: 10) {
                    if isRequesting {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Image(systemName: "shield.checkered")
                        Text("Allow Screen Time Access")
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isRequesting)

            Text("Required to block apps & websites during focus sessions.\nNo data leaves your device.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func requestPermission() {
        isRequesting = true
        errorMessage = nil
        Task {
            await appState.requestAuthorization()
            isRequesting = false
            if !appState.isAuthorized {
                errorMessage = "Permission denied. You can enable it later in Settings → Screen Time."
            }
        }
    }
}
