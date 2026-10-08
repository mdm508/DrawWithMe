import PencilKit
import SwiftUI
import UIKit

struct Dwm11LayoutSpikeView: View {
    @State private var drawing = Self.sampleDrawing()
    @State private var selectedColorID = "red"
    @State private var secretWordIsHidden = false
    @State private var typedGuess = ""
    @State private var canvasViewport = CGSize(width: 560, height: 300)

    private let playerGap: CGFloat = 52
    private let palette = PaletteColor.standardSet

    private var selectedInkColor: UIColor {
        palette.first(where: { $0.id == selectedColorID })?.uiColor ?? .systemRed
    }

    private var hintWithTypedLetters: String {
        let enteredLetters = Array(typedGuess)
        let hintLength = max(9, enteredLetters.count)
        return (0..<hintLength)
            .map { index in index < enteredLetters.count ? String(enteredLetters[index]) : "_" }
            .joined(separator: " ")
    }

    var body: some View {
        GeometryReader { geometry in
            let paneHeight = max(0, (geometry.size.height - playerGap) / 2)

            ZStack {
                VStack(spacing: 0) {
                    guesserHalf(rotated: true)
                        .frame(height: paneHeight)
                    playerSeparator
                    drawerHalf(rotated: false)
                        .frame(height: paneHeight)
                }
            }
            .background(Color(red: 0.96, green: 0.95, blue: 0.91))
        }
        .background(Color(red: 0.96, green: 0.95, blue: 0.91))
    }

    private var playerSeparator: some View {
        Rectangle()
            .fill(Color(red: 0.96, green: 0.95, blue: 0.91))
            .overlay(alignment: .center) {
                Image(systemName: "timer")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.blue)
                    .frame(width: 36, height: 36)
                    .background(.white, in: Circle())
                    .accessibilityLabel("Blue turn timer placeholder")
            }
            .frame(height: playerGap)
    }

    private func drawerHalf(rotated: Bool) -> some View {
        VStack(spacing: 8) {
            HStack {
                Label("DRAWER · PLAYER 1", systemImage: "pencil.tip.crop.circle")
                    .font(.caption.weight(.bold))
                Spacer()
                Label("Medium pen", systemImage: "pencil.tip")
                    .font(.caption2.weight(.semibold))
            }
            .frame(minHeight: 32)

            HStack(spacing: 8) {
                Text("SECRET WORD")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(secretWordIsHidden ? "•••••••••" : "butterfly")
                    .font(.headline.weight(.semibold))
                Spacer(minLength: 0)
                Text(secretWordIsHidden ? "hold to reveal" : "hold to hide")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 40)
            .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 12))
            .onLongPressGesture(minimumDuration: 0.15) {
                secretWordIsHidden.toggle()
            }

            GeometryReader { toolsArea in
                HStack(spacing: 6) {
                    colorRail(colors: Array(palette.prefix(4)))

                    GeometryReader { canvasArea in
                        SpikeDrawingCanvasView(drawing: $drawing, inkColor: selectedInkColor)
                            .onAppear { canvasViewport = canvasArea.size }
                            .onChange(of: canvasArea.size) { _, size in
                                canvasViewport = size
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.black.opacity(0.12), lineWidth: 1)
                    }

                    VStack(spacing: 6) {
                        Button {
                            drawing = PKDrawing()
                        } label: {
                            Text("💣")
                                .font(.system(size: 24))
                                .foregroundStyle(.red)
                                .frame(minWidth: 44, minHeight: 44)
                                .background(.white, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Clear all drawing")
                        .accessibilityHint("Removes the drawing from both player views")

                        colorRail(colors: Array(palette.suffix(4)))
                    }
                }
                .frame(width: toolsArea.size.width, height: toolsArea.size.height)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.91, green: 0.89, blue: 0.82))
        .rotationEffect(.degrees(rotated ? 180 : 0))
    }

    private func colorRail(colors: [PaletteColor]) -> some View {
        VStack(spacing: 4) {
            ForEach(colors) { color in
                Button {
                    selectedColorID = color.id
                } label: {
                    Circle()
                        .fill(color.swiftUIColor)
                        .frame(width: 28, height: 28)
                        .overlay {
                            Circle()
                                .stroke(.white, lineWidth: selectedColorID == color.id ? 3 : 0)
                                .padding(2)
                        }
                        .overlay {
                            Circle()
                                .stroke(.black.opacity(0.28), lineWidth: 1)
                        }
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(color.name) pen color")
                .accessibilityAddTraits(selectedColorID == color.id ? .isSelected : [])
            }
        }
        .frame(width: 42)
    }

    private func guesserHalf(rotated: Bool) -> some View {
        GeometryReader { geometry in
            let availableWidth = max(0, geometry.size.width - 16)
            let keyHeight = min(28, max(18, (geometry.size.height - 100) / 3))
            let keyboardHeight = keyHeight * 3 + 4
            let fixedContentHeight = 22 + 32 + keyboardHeight + 40
            let previewAreaHeight = min(
                geometry.size.height * 0.5,
                max(0, geometry.size.height - fixedContentHeight)
            )
            let aspectRatio = canvasViewport.width / max(canvasViewport.height, 1)
            let mirrorMaxWidth = min(availableWidth * 0.82, 500)
            let previewWidth = min(mirrorMaxWidth, previewAreaHeight * aspectRatio)
            let previewHeight = previewWidth / max(aspectRatio, 0.1)
            let contentWidth = min(availableWidth, max(180, previewWidth + 28))

            VStack(spacing: 3) {
                HStack {
                    Text("GUESSER · PLAYER 2")
                        .font(.caption.weight(.bold))
                }
                .frame(minHeight: 22)

                DrawingMirror(drawing: drawing, viewport: canvasViewport)
                    .frame(width: previewWidth, height: previewHeight)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 4) {
                    Text(hintWithTypedLetters)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                        .frame(width: previewWidth, height: 30)
                        .background(.white, in: RoundedRectangle(cornerRadius: 8))
                        .accessibilityLabel(typedGuess.isEmpty
                                            ? "Hint: nine letters"
                                            : "Guess so far: \(typedGuess), nine letters")

                    GuessKeyboard(typedGuess: $typedGuess, keyHeight: keyHeight) {
                        guard !typedGuess.isEmpty else { return }
                        typedGuess = ""
                    }
                    .frame(width: contentWidth, height: keyboardHeight)
                }
                .frame(width: contentWidth)
            }
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.88, green: 0.91, blue: 0.93))
        }
        .rotationEffect(.degrees(rotated ? 180 : 0))
    }

    private static func sampleDrawing() -> PKDrawing {
        let strokes: [[CGPoint]] = [
            [CGPoint(x: 190, y: 180), CGPoint(x: 225, y: 215), CGPoint(x: 270, y: 150), CGPoint(x: 315, y: 85)],
            [CGPoint(x: 345, y: 95), CGPoint(x: 385, y: 75), CGPoint(x: 420, y: 100), CGPoint(x: 410, y: 135)],
            [CGPoint(x: 180, y: 250), CGPoint(x: 280, y: 250), CGPoint(x: 420, y: 250)]
        ]
        let colors: [UIColor] = [.systemPink, .systemBlue, .systemGreen]

        return PKDrawing(strokes: zip(strokes, colors).map { points, color in
            let controlPoints = points.enumerated().map { index, location in
                PKStrokePoint(
                    location: location,
                    timeOffset: Double(index) * 0.08,
                    size: CGSize(width: 10, height: 10),
                    opacity: 1,
                    force: 1,
                    azimuth: 0,
                    altitude: .pi / 2
                )
            }
            let path = PKStrokePath(controlPoints: controlPoints, creationDate: Date())
            return PKStroke(ink: PKInk(.pen, color: color), path: path)
        })
    }
}

private struct PaletteColor: Identifiable {
    let id: String
    let name: String
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat

    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    var swiftUIColor: Color { Color(uiColor) }

    static let standardSet = [
        PaletteColor(id: "red", name: "Red", red: 0.91, green: 0.12, blue: 0.15),
        PaletteColor(id: "orange", name: "Orange", red: 1.00, green: 0.48, blue: 0.08),
        PaletteColor(id: "yellow", name: "Yellow", red: 1.00, green: 0.86, blue: 0.08),
        PaletteColor(id: "green", name: "Green", red: 0.12, green: 0.62, blue: 0.28),
        PaletteColor(id: "blue", name: "Blue", red: 0.08, green: 0.39, blue: 0.83),
        PaletteColor(id: "violet", name: "Violet", red: 0.45, green: 0.20, blue: 0.63),
        PaletteColor(id: "brown", name: "Brown", red: 0.48, green: 0.28, blue: 0.15),
        PaletteColor(id: "black", name: "Black", red: 0.08, green: 0.08, blue: 0.09)
    ]
}

private struct DrawingMirror: View {
    let drawing: PKDrawing
    let viewport: CGSize

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                if drawing.bounds.isEmpty {
                    Text("Draw above to see the live mirror")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                } else if viewport.width > 0, viewport.height > 0 {
                    Image(uiImage: drawing.image(
                        from: CGRect(origin: .zero, size: viewport),
                        scale: 1
                    ))
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.black.opacity(0.12), lineWidth: 1)
            }
        }
        .accessibilityLabel("Live drawing preview at a fixed size")
    }
}

private struct SpikeDrawingCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    let inkColor: UIColor

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.backgroundColor = .white
        canvas.delegate = context.coordinator
        canvas.tool = PKInkingTool(.pen, color: inkColor, width: 7)
        canvas.drawingPolicy = .anyInput
        canvas.isScrollEnabled = false
        canvas.alwaysBounceHorizontal = false
        canvas.alwaysBounceVertical = false
        canvas.minimumZoomScale = 1
        canvas.maximumZoomScale = 1
        canvas.isOpaque = true
        canvas.overrideUserInterfaceStyle = .light
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        let currentTool = canvas.tool as? PKInkingTool
        if currentTool?.color != inkColor || currentTool?.width != 7 {
            canvas.tool = PKInkingTool(.pen, color: inkColor, width: 7)
        }
        guard canvas.drawing.dataRepresentation() != drawing.dataRepresentation() else {
            return
        }
        context.coordinator.isApplyingExternalDrawing = true
        canvas.drawing = drawing
        context.coordinator.isApplyingExternalDrawing = false
    }

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

private struct GuessKeyboard: View {
    @Binding var typedGuess: String
    let keyHeight: CGFloat
    let submit: () -> Void

    private let rows = [Array("qwertyuiop"), Array("asdfghjkl"), Array("zxcvbnm")]

    var body: some View {
        GeometryReader { geometry in
            let keySpacing: CGFloat = 2
            let keyWidth = max(0, (geometry.size.width - keySpacing * 9) / 10)
            let fontSize = min(14, max(9, keyHeight * 0.46))

            VStack(spacing: keySpacing) {
                ForEach(Array(rows.prefix(2).enumerated()), id: \.offset) { _, row in
                    HStack(spacing: keySpacing) {
                        ForEach(row, id: \.self) { character in
                            key(character, width: keyWidth, fontSize: fontSize)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                HStack(spacing: keySpacing) {
                    ForEach(rows.last ?? [], id: \.self) { character in
                        key(character, width: keyWidth, fontSize: fontSize)
                    }
                    Button("Submit", action: submit)
                        .font(.system(size: fontSize, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(width: keyWidth * 2 + keySpacing, height: keyHeight)
                        .background(.white, in: RoundedRectangle(cornerRadius: 5))
                        .disabled(typedGuess.isEmpty)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
    }

    private func key(_ character: Character, width: CGFloat, fontSize: CGFloat) -> some View {
        let title = String(character)
        return Button(title, action: { typedGuess.append(character) })
            .font(.system(size: fontSize, weight: .semibold))
            .frame(width: width, height: keyHeight)
            .background(.white, in: RoundedRectangle(cornerRadius: 5))
            .accessibilityLabel(title)
    }
}
