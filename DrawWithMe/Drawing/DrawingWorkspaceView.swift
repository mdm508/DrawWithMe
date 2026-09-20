import PencilKit
import SwiftUI

/// Adaptive practice workspace used to refine core drawing interaction.
///
/// The view leads with iPad landscape ergonomics but deliberately uses the same
/// tool model for compact iPhone layouts and Mac Catalyst pointer input.
struct DrawingWorkspaceView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var drawing = PKDrawing()
    @State private var tool: DrawingTool = .pen
    @AppStorage("drawing.preferredWidth") private var preferredWidth = DrawingWidth.medium.rawValue
    @AppStorage("drawing.preferredColor") private var preferredColor = DrawingColor.black.rawValue

    private var widthBinding: Binding<DrawingWidth> {
        Binding(
            get: { DrawingWidth(rawValue: preferredWidth) ?? .medium },
            set: { preferredWidth = $0.rawValue }
        )
    }

    private var colorBinding: Binding<DrawingColor> {
        Binding(
            get: { DrawingColor(rawValue: preferredColor) ?? .black },
            set: { preferredColor = $0.rawValue }
        )
    }

    private var selection: DrawingToolSelection {
        DrawingToolSelection(
            tool: tool,
            width: widthBinding.wrappedValue,
            color: colorBinding.wrappedValue
        )
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let usesSideToolbar = horizontalSizeClass == .regular && proxy.size.width > 760

                Group {
                    if usesSideToolbar {
                        HStack(spacing: 16) {
                            canvas
                            toolbar(orientation: .vertical)
                        }
                    } else {
                        VStack(spacing: 12) {
                            canvas
                            ScrollView(.horizontal, showsIndicators: false) {
                                toolbar(orientation: .horizontal)
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("DrawWithMe")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Label("Practice canvas", systemImage: "person.2")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var canvas: some View {
        DrawingCanvasView(drawing: $drawing, selection: selection)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.quaternary, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
            .accessibilityLabel("Drawing canvas")
    }

    private func toolbar(orientation: Axis) -> some View {
        DrawingToolbar(
            tool: $tool,
            width: widthBinding,
            color: colorBinding,
            orientation: orientation,
            clear: { drawing = PKDrawing() }
        )
    }
}

#Preview("Compact finger layout") {
    DrawingWorkspaceView()
}

