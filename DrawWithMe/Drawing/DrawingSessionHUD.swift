import SwiftUI

/// Compact game information layered over the drawing surface.
///
/// The three zones are intentionally small and replaceable:
///
/// - Leading: party presence and room context.
/// - Center: the current word, phase, or timer.
/// - Trailing: infrequent canvas-wide actions.
///
/// None of these zones reserves a permanent sidebar or bottom bar, so the same
/// drawing surface remains viable on iPad and compact iPhone layouts.
struct DrawingSessionHUD: View {
    let roomLabel: String
    let participantCount: Int
    let activityLabel: String
    let clearDrawing: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            partyIndicator
            Spacer(minLength: 8)
            activityIndicator
            Spacer(minLength: 8)
            clearButton
        }
        .font(.subheadline.weight(.semibold))
    }

    private var partyIndicator: some View {
        Label {
            ViewThatFits(in: .horizontal) {
                Text("\(roomLabel) · \(participantCount)")
                Text("\(participantCount)")
            }
        } icon: {
            Image(systemName: participantCount == 1 ? "person.fill" : "person.2.fill")
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 44)
        .background(.regularMaterial, in: Capsule())
        .accessibilityLabel(
            "\(roomLabel), \(participantCount) \(participantCount == 1 ? "participant" : "participants")"
        )
    }

    private var activityIndicator: some View {
        Text(activityLabel)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(.regularMaterial, in: Capsule())
            .accessibilityLabel("Drawing activity: \(activityLabel)")
    }

    private var clearButton: some View {
        Button(role: .destructive, action: clearDrawing) {
            Image(systemName: "trash")
                .frame(width: 44, height: 44)
                .background(.regularMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.red)
        .accessibilityLabel("Clear drawing")
    }
}

#Preview("Drawing HUD") {
    DrawingSessionHUD(
        roomLabel: "Room",
        participantCount: 5,
        activityLabel: "Cat · 0:42",
        clearDrawing: {}
    )
    .padding()
    .background(Color.white)
}
