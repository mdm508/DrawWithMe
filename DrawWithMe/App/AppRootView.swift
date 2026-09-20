import SwiftUI

/// Root composition surface for the current vertical slice.
///
/// Live rooms will replace the practice header after the Game Center adapter is
/// connected. Keeping the drawing workspace independent makes input quality
/// testable before authentication or networking is available.
struct AppRootView: View {
    var body: some View {
        DrawingWorkspaceView()
    }
}

#Preview("iPad drawing workspace") {
    AppRootView()
}
