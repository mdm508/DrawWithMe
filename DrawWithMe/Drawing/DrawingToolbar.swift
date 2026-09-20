import SwiftUI

/// Compact, glanceable controls that remain reachable during a timed turn.
struct DrawingToolbar: View {
    @Binding var tool: DrawingTool
    @Binding var width: DrawingWidth
    @Binding var color: DrawingColor
    let orientation: Axis
    let clear: () -> Void

    @State private var confirmsClear = false

    var body: some View {
        Group {
            if orientation == .horizontal {
                HStack(spacing: 12) { controls }
            } else {
                VStack(spacing: 14) { controls }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .confirmationDialog(
            "Clear the whole drawing?",
            isPresented: $confirmsClear,
            titleVisibility: .visible
        ) {
            Button("Clear Drawing", role: .destructive, action: clear)
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var controls: some View {
        toolButtons
        Divider()
        colorButtons
        Divider()
        widthButtons
        Divider()
        Button(role: .destructive) {
            confirmsClear = true
        } label: {
            Label("Clear", systemImage: "bomb")
                .labelStyle(.iconOnly)
                .frame(minWidth: 36, minHeight: 36)
        }
        .accessibilityLabel("Clear drawing")
    }

    private var toolButtons: some View {
        adaptiveGroup {
            ForEach(DrawingTool.allCases) { candidate in
                selectionButton(
                    title: candidate.label,
                    systemImage: candidate.systemImage,
                    isSelected: tool == candidate
                ) {
                    tool = candidate
                }
            }
        }
    }

    private var colorButtons: some View {
        adaptiveGroup {
            ForEach(DrawingColor.allCases) { candidate in
                Button {
                    color = candidate
                    tool = .pen
                } label: {
                    Circle()
                        .fill(candidate.color)
                        .frame(width: 28, height: 28)
                        .overlay {
                            Circle()
                                .stroke(.primary, lineWidth: color == candidate ? 3 : 0)
                                .padding(-4)
                        }
                        .frame(minWidth: 36, minHeight: 36)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(candidate.label) ink")
                .accessibilityAddTraits(color == candidate ? .isSelected : [])
            }
        }
    }

    private var widthButtons: some View {
        adaptiveGroup {
            ForEach(DrawingWidth.allCases) { candidate in
                Button {
                    width = candidate
                    tool = .pen
                } label: {
                    Circle()
                        .fill(.primary)
                        .frame(width: candidate.points, height: candidate.points)
                        .frame(minWidth: 36, minHeight: 36)
                        .background {
                            if width == candidate {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.tint.opacity(0.18))
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(candidate.label) line")
                .accessibilityAddTraits(width == candidate ? .isSelected : [])
            }
        }
    }

    @ViewBuilder
    private func adaptiveGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if orientation == .horizontal {
            HStack(spacing: 8, content: content)
        } else {
            VStack(spacing: 8, content: content)
        }
    }

    private func selectionButton(
        title: String,
        systemImage: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(minWidth: 36, minHeight: 36)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.tint.opacity(0.18))
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

