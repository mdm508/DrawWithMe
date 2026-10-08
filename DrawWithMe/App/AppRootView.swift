import SwiftUI

struct AppRootView: View {
    var body: some View {
        NavigationStack {
            Dwm11LayoutSpikeView()
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview("Dwm11 layout spike") {
    AppRootView()
}
