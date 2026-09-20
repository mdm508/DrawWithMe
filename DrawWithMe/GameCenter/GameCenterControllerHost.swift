import SwiftUI
import UIKit

/// Presents a GameKit-owned UIKit controller inside the SwiftUI app shell.
///
/// Game Center owns the controller lifecycle and content. This representable is
/// deliberately passive so SwiftUI does not accidentally rebuild or configure
/// Apple's authentication and matchmaking interfaces.
struct GameCenterControllerHost: UIViewControllerRepresentable {
    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
