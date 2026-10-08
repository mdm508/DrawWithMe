import PencilKit
import SwiftUI

struct Dwm11LayoutSpikeView: View {
    @State private var drawing = PKDrawing()
    @State private var drawerIsAtTop = false
    @State private var secretWordIsHidden = false
    @State private var typedGuess = ""
    @State private var recentGuesses = ["planit", "plant", "planet"]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    if drawerIsAtTop {
                        drawerHalf(rotated: true)
                        Divider()
                        guesserHalf(rotated: false)
                    } else {
                        guesserHalf(rotated: true)
                        Divider()
                        drawerHalf(rotated: false)
                    }
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        drawerIsAtTop.toggle()
                    }
                } label: {
                    Label("Swap roles", systemImage: "arrow.up.arrow.down")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .frame(minHeight: 44)
                        .background(.regularMaterial, in: Capsule())
                }
                .accessibilityHint("Moves the active PencilKit canvas to the opposite half")
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .background(Color(red: 0.96, green: 0.95, blue: 0.91))
        }
        .background(Color(red: 0.96, green: 0.95, blue: 0.91))
    }

    private func drawerHalf(rotated: Bool) -> some View {
        VStack(spacing: 8) {
            HStack {
                Label("DRAWER · PLAYER 1", systemImage: "pencil.tip.crop.circle")
                    .font(.caption.weight(.bold))
                Spacer()
                Text("01:00")
                    .font(.caption.monospacedDigit().weight(.semibold))
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

            DrawingCanvasView(drawing: $drawing)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.black.opacity(0.12), lineWidth: 1)
                }
                .id(rotated)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.91, green: 0.89, blue: 0.82))
        .rotationEffect(.degrees(rotated ? 180 : 0))
    }

    private func guesserHalf(rotated: Bool) -> some View {
        VStack(spacing: 6) {
            GuessKeyboard(typedGuess: $typedGuess) {
                guard !typedGuess.isEmpty else { return }
                recentGuesses.insert(typedGuess, at: 0)
                recentGuesses = Array(recentGuesses.prefix(3))
                typedGuess = ""
            }

            HStack(spacing: 8) {
                Text(typedGuess.isEmpty ? "type your guess" : typedGuess)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button("Clear") { typedGuess = "" }
                    .font(.caption.weight(.semibold))
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityLabel("Clear guess")
            }
            .padding(.horizontal, 12)
            .background(.white, in: RoundedRectangle(cornerRadius: 10))

            HStack(spacing: 8) {
                Text("HINT")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                Text("_ _ _ _ _ _ _ _")
                    .font(.headline.monospaced())
                    .tracking(2)
                Spacer()
                Text("GUESSES")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .frame(minHeight: 28)

            HStack(spacing: 6) {
                ForEach(Array(recentGuesses.prefix(3).enumerated()), id: \.offset) { index, guess in
                    Text(guess)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                        .frame(minHeight: 30)
                        .background(index == 0 ? Color.yellow.opacity(0.45) : .white,
                                    in: Capsule())
                }
                Spacer(minLength: 0)
            }

            DrawingMirror(drawing: drawing)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: 62, maxHeight: 104)

            HStack {
                Text("GUESSER · PLAYER 2")
                    .font(.caption.weight(.bold))
                Spacer()
                Text("mirrored drawing · live")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(minHeight: 28)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.88, green: 0.91, blue: 0.93))
        .rotationEffect(.degrees(rotated ? 180 : 0))
    }
}

private struct DrawingMirror: View {
    let drawing: PKDrawing

    var body: some View {
        Group {
            if drawing.bounds.isEmpty {
                ZStack {
                    Color.white
                    Text("DRAWING PREVIEW")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            } else {
                Image(uiImage: drawing.image(from: drawing.bounds, scale: 0.35))
                    .resizable()
                    .scaledToFit()
                    .background(.white)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black.opacity(0.12), lineWidth: 1)
        }
        .accessibilityLabel("Live drawing preview")
    }
}

private struct GuessKeyboard: View {
    @Binding var typedGuess: String
    let submit: () -> Void

    private let rows = [Array("qwertyuiop"), Array("asdfghjkl"), Array("zxcvbnm")]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { character in
                        key(character)
                    }
                    if row.count == 7 {
                        Button("⌫") { if !typedGuess.isEmpty { typedGuess.removeLast() } }
                            .font(.caption.weight(.bold))
                            .frame(minWidth: 44, minHeight: 44)
                            .background(.white, in: RoundedRectangle(cornerRadius: 7))
                            .accessibilityLabel("Delete last character")
                    }
                }
            }

            HStack(spacing: 4) {
                Button("Space") { typedGuess.append(" ") }
                    .frame(width: 72, height: 44)
                Button("Submit", action: submit)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .disabled(typedGuess.isEmpty)
            }
            .font(.caption)
            .background(.white, in: RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }

    private func key(_ character: Character) -> some View {
        let title = String(character)
        return Button(title, action: { typedGuess.append(character) })
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(.white, in: RoundedRectangle(cornerRadius: 7))
            .accessibilityLabel(title)
    }
}
