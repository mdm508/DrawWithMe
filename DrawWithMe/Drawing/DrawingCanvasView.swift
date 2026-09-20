import PencilKit
import SwiftUI

/// SwiftUI bridge for the PencilKit drawing surface.
///
/// This is the only type in the feature that owns a `PKCanvasView`. Keeping the
/// bridge narrow prevents game rules and networking from depending on UIKit.
struct DrawingCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    let selection: DrawingToolSelection

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.backgroundColor = .systemBackground
        canvas.delegate = context.coordinator
        canvas.drawingPolicy = .anyInput
        canvas.alwaysBounceVertical = false
        canvas.alwaysBounceHorizontal = false
        canvas.isOpaque = true
        canvas.tool = selection.pencilKitTool
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        canvas.tool = selection.pencilKitTool

        guard canvas.drawing.dataRepresentation() != drawing.dataRepresentation() else {
            return
        }

        context.coordinator.isApplyingExternalDrawing = true
        canvas.drawing = drawing
        context.coordinator.isApplyingExternalDrawing = false
    }

    /// Relays user-created drawing changes back to SwiftUI while preventing an
    /// externally applied snapshot from echoing back as a local edit.
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding private var drawing: PKDrawing
        var isApplyingExternalDrawing = false

        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            guard !isApplyingExternalDrawing else { return }
            drawing = canvasView.drawing
        }
    }
}

