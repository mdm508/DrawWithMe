import SwiftUI

/// Opens directly into local free drawing while online play is deferred.
///
/// The root does not create a Game Center coordinator, so drawing never waits
/// for authentication or presents matchmaking UI.
struct AppRootView: View {
    var body: some View {
        NavigationStack {
            DrawingWorkspaceView()
        }
    }
}

#Preview("App home") {
    AppRootView()
}
