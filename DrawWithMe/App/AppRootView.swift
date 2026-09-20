import SwiftUI

/// Root composition surface for identity, matchmaking, and drawing practice.
struct AppRootView: View {
    @StateObject private var gameCenter = GameCenterCoordinator()

    var body: some View {
        GameCenterHomeView(coordinator: gameCenter)
    }
}

#Preview("App home") {
    AppRootView()
}
