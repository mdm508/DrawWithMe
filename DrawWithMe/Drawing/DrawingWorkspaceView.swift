import PencilKit
import SwiftUI

/// Adaptive practice workspace used to refine core drawing interaction.
///
/// The canvas consumes the full content area. Apple owns the movable drawing
/// picker, while game information occupies small overlay zones instead of
/// permanently shrinking the surface.
struct DrawingWorkspaceView: View {
    @State private var drawing = PKDrawing()
    @State private var confirmsClear = false

    var body: some View {
        ZStack(alignment: .top) {
            DrawingCanvasView(drawing: $drawing)
                .background(Color.white)
                .accessibilityLabel("Drawing canvas")

            DrawingSessionHUD(
                roomLabel: "Practice",
                participantCount: 1,
                activityLabel: "Free Draw",
                clearDrawing: { confirmsClear = true }
            )
            .padding(12)
        }
        .navigationTitle("Canvas")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Clear the whole drawing?",
            isPresented: $confirmsClear,
            titleVisibility: .visible
        ) {
            Button("Clear Drawing", role: .destructive) {
                drawing = PKDrawing()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview("Compact finger layout") {
    DrawingWorkspaceView()
}
