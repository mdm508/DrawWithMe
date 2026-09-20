import PencilKit
import SwiftUI

/// SwiftUI bridge for the PencilKit drawing surface.
///
/// This is the only type in the feature that owns a `PKCanvasView`. Keeping the
/// bridge narrow prevents game rules and networking from depending on UIKit.
struct DrawingCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing

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
        canvas.overrideUserInterfaceStyle = .light
        context.coordinator.attachToolPicker(to: canvas)
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        guard canvas.drawing.dataRepresentation() != drawing.dataRepresentation() else {
            return
        }

        context.coordinator.isApplyingExternalDrawing = true
        canvas.drawing = drawing
        context.coordinator.isApplyingExternalDrawing = false
    }

    static func dismantleUIView(_ canvas: PKCanvasView, coordinator: Coordinator) {
        coordinator.detachToolPicker(from: canvas)
    }

    /// Relays user-created drawing changes back to SwiftUI while preventing an
    /// externally applied snapshot from echoing back as a local edit.
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding private var drawing: PKDrawing
        private let toolPicker = PKToolPicker()
        var isApplyingExternalDrawing = false

        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }

        /// Connects Apple's movable picker and restores its last local state.
        ///
        /// The picker is deliberately owned by the adapter instead of SwiftUI:
        /// it must outlive view updates and observe the exact canvas responder.
        func attachToolPicker(to canvas: PKCanvasView) {
            toolPicker.stateAutosaveName = "DrawWithMe.DrawingTools"
            toolPicker.showsDrawingPolicyControls = true
            toolPicker.overrideUserInterfaceStyle = .light
            toolPicker.colorUserInterfaceStyle = .light
            toolPicker.addObserver(canvas)

            DispatchQueue.main.async { [weak canvas, weak self] in
                guard let canvas, let self else { return }
                canvas.becomeFirstResponder()
                self.toolPicker.setVisible(true, forFirstResponder: canvas)
            }
        }

        /// Releases the responder relationship when SwiftUI removes the canvas.
        func detachToolPicker(from canvas: PKCanvasView) {
            toolPicker.setVisible(false, forFirstResponder: canvas)
            toolPicker.removeObserver(canvas)
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            guard !isApplyingExternalDrawing else { return }
            drawing = canvasView.drawing
        }
    }
}
