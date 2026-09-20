import SwiftUI

/// Entry screen for Game Center identity, private invitations, and local practice.
struct GameCenterHomeView: View {
    @ObservedObject var coordinator: GameCenterCoordinator

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    title
                    identityCard
                    playActions
                    matchmakingStatus
                }
                .frame(maxWidth: 560)
                .padding(24)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("DrawWithMe")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $coordinator.presentation, onDismiss: coordinator.presentationDidDismiss) { presentation in
            GameCenterControllerHost(viewController: presentation.viewController)
                .ignoresSafeArea()
        }
        .task {
            coordinator.authenticateIfNeeded()
        }
    }

    private var title: some View {
        VStack(spacing: 10) {
            Image(systemName: "scribble.variable")
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("Draw together. Guess fast.")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("A Pencil-first party game for iPhone, iPad, and Mac.")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private var identityCard: some View {
        GroupBox {
            HStack(spacing: 14) {
                Image(systemName: identitySymbol)
                    .font(.title2)
                    .foregroundStyle(identityColor)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(identityTitle)
                        .font(.headline)
                    Text(identityDetail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
        } label: {
            Label("Game Center", systemImage: "gamecontroller.fill")
        }
    }

    private var playActions: some View {
        VStack(spacing: 12) {
            Button(action: primaryAction) {
                Label(primaryActionTitle, systemImage: "person.3.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            NavigationLink {
                DrawingWorkspaceView()
            } label: {
                Label("Practice Drawing", systemImage: "pencil.and.outline")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    @ViewBuilder
    private var matchmakingStatus: some View {
        switch coordinator.matchmakingState {
        case .idle:
            EmptyView()
        case .findingPlayers:
            statusLabel("Finding players…", symbol: "person.2.wave.2", color: .accentColor)
        case let .matched(participantCount):
            statusLabel(
                "Connected \(participantCount) players. Room synchronization is next.",
                symbol: "checkmark.circle.fill",
                color: .green
            )
        case .cancelled:
            statusLabel("Matchmaking cancelled.", symbol: "xmark.circle", color: .secondary)
        case let .failed(message):
            statusLabel(message, symbol: "exclamationmark.triangle.fill", color: .orange)
        }
    }

    private func statusLabel(_ text: String, symbol: String, color: Color) -> some View {
        Label(text, systemImage: symbol)
            .font(.subheadline)
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }

    private var authenticatedIdentity: GameCenterCoordinator.PlayerIdentity? {
        guard case let .authenticated(identity) = coordinator.identityState else { return nil }
        return identity
    }

    private var identityTitle: String {
        authenticatedIdentity?.displayName ?? "Game Center sign-in"
    }

    private var identityDetail: String {
        switch coordinator.identityState {
        case .idle:
            "Preparing Game Center…"
        case .authenticating:
            "Waiting for authentication"
        case .authenticated:
            "Ready for private rooms and invitations"
        case let .unavailable(message):
            message
        }
    }

    private var identitySymbol: String {
        authenticatedIdentity == nil ? "person.crop.circle.badge.questionmark" : "checkmark.seal.fill"
    }

    private var identityColor: Color {
        authenticatedIdentity == nil ? .secondary : .green
    }

    private var primaryActionTitle: String {
        authenticatedIdentity == nil ? "Continue with Game Center" : "Create or Join Private Room"
    }

    private func primaryAction() {
        if authenticatedIdentity == nil {
            coordinator.authenticateIfNeeded()
        } else {
            coordinator.startPrivateMatchmaking()
        }
    }
}

#Preview("Game Center home") {
    GameCenterHomeView(coordinator: GameCenterCoordinator())
}
