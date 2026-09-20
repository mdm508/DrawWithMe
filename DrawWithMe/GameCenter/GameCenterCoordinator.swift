import Combine
import GameKit
import UIKit

/// Coordinates Game Center identity, invitations, and Apple's private matchmaker UI.
///
/// This is the only object in the app shell that talks directly to GameKit. A
/// successful match remains here until the networking adapter takes ownership,
/// which prevents `GKMatch` from leaking into the room domain or SwiftUI views.
@MainActor
final class GameCenterCoordinator: NSObject, ObservableObject {
    /// The current authentication outcome for the local player.
    enum IdentityState: Equatable {
        case idle
        case authenticating
        case authenticated(PlayerIdentity)
        case unavailable(message: String)
    }

    /// The current private-matchmaking outcome.
    enum MatchmakingState: Equatable {
        case idle
        case findingPlayers
        case matched(participantCount: Int)
        case cancelled
        case failed(message: String)
    }

    /// A stable, framework-independent description of the local Game Center player.
    struct PlayerIdentity: Equatable {
        let identifier: String
        let displayName: String
    }

    /// A UIKit controller that SwiftUI must present on GameKit's behalf.
    struct Presentation: Identifiable {
        enum Purpose {
            case authentication
            case matchmaking
        }

        let id = UUID()
        let purpose: Purpose
        let viewController: UIViewController
    }

    /// Authentication state rendered by the app shell.
    @Published private(set) var identityState: IdentityState = .idle

    /// Private-matchmaking state rendered by the app shell.
    @Published private(set) var matchmakingState: MatchmakingState = .idle

    /// The system Game Center controller currently presented by SwiftUI.
    @Published var presentation: Presentation?

    /// The established match awaiting handoff to the real-time transport.
    ///
    /// - Important: Only the future GameKit transport adapter should call
    ///   ``takePendingMatch()``. Views render `matchmakingState` instead.
    private var pendingMatch: GKMatch?

    /// Starts authentication unless the local player is already authenticated.
    func authenticateIfNeeded() {
        guard !GKLocalPlayer.local.isAuthenticated else {
            finishAuthentication()
            return
        }
        guard identityState != .authenticating else { return }

        identityState = .authenticating
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self else { return }
            self.handleAuthentication(viewController: viewController, error: error)
        }
    }

    /// Presents Apple's private real-time matchmaker for two to seven players.
    ///
    /// The matchmaker supports direct invitations and automatching. Public room
    /// discovery remains outside v1 even though GameKit may fill empty seats.
    func startPrivateMatchmaking() {
        guard GKLocalPlayer.local.isAuthenticated else {
            authenticateIfNeeded()
            return
        }

        let runtimeMaximum = GKMatchRequest.maxPlayersAllowedForMatch(of: .peerToPeer)
        let supportedMaximum = min(RoomConfiguration.maximumParticipantCount, runtimeMaximum)
        guard supportedMaximum >= 2 else {
            matchmakingState = .failed(message: "This device cannot create a multiplayer match.")
            return
        }

        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = supportedMaximum
        request.inviteMessage = "Join my DrawWithMe room!"

        guard let viewController = GKMatchmakerViewController(matchRequest: request) else {
            matchmakingState = .failed(message: "Game Center matchmaking is unavailable.")
            return
        }

        viewController.matchmakerDelegate = self
        matchmakingState = .findingPlayers
        presentation = Presentation(purpose: .matchmaking, viewController: viewController)
    }

    /// Clears transient UI state when a Game Center controller is dismissed.
    func presentationDidDismiss() {
        presentation = nil
        if matchmakingState == .findingPlayers {
            matchmakingState = .cancelled
        }
    }

    /// Transfers the established GameKit match to the transport layer exactly once.
    ///
    /// - Returns: The pending match, or `nil` when matchmaking has not completed.
    func takePendingMatch() -> GKMatch? {
        defer { pendingMatch = nil }
        return pendingMatch
    }

    private func handleAuthentication(viewController: UIViewController?, error: Error?) {
        if let viewController {
            presentation = Presentation(purpose: .authentication, viewController: viewController)
            return
        }

        if GKLocalPlayer.local.isAuthenticated {
            finishAuthentication()
        } else {
            presentation = nil
            identityState = .unavailable(
                message: error?.localizedDescription ?? "Sign in to Game Center in Settings to play online."
            )
        }
    }

    private func finishAuthentication() {
        let player = GKLocalPlayer.local
        identityState = .authenticated(
            PlayerIdentity(identifier: player.gamePlayerID, displayName: player.displayName)
        )
        presentation = nil
        player.unregisterAllListeners()
        player.register(self)
    }

    private func presentAcceptedInvite(_ invite: GKInvite) {
        guard let viewController = GKMatchmakerViewController(invite: invite) else {
            matchmakingState = .failed(message: "The invitation is no longer available.")
            return
        }

        viewController.matchmakerDelegate = self
        matchmakingState = .findingPlayers
        presentation = Presentation(purpose: .matchmaking, viewController: viewController)
    }
}

// MARK: - Game Center callbacks

extension GameCenterCoordinator: GKLocalPlayerListener {
    /// Opens an accepted invitation in the same matchmaker flow as a room created locally.
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        presentAcceptedInvite(invite)
    }
}

extension GameCenterCoordinator: GKMatchmakerViewControllerDelegate {
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        matchmakingState = .cancelled
        presentation = nil
    }

    func matchmakerViewController(
        _ viewController: GKMatchmakerViewController,
        didFailWithError error: Error
    ) {
        matchmakingState = .failed(message: error.localizedDescription)
        presentation = nil
    }

    func matchmakerViewController(
        _ viewController: GKMatchmakerViewController,
        didFind match: GKMatch
    ) {
        pendingMatch = match
        matchmakingState = .matched(participantCount: match.players.count + 1)
        presentation = nil
    }
}
