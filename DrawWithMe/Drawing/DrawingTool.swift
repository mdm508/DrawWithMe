import PencilKit
import SwiftUI
import UIKit

/// The intentionally small drawing toolset promised by v1.
enum DrawingTool: String, CaseIterable, Identifiable {
    case pen
    case eraser

    var id: String { rawValue }

    var label: String {
        switch self {
        case .pen: "Pen"
        case .eraser: "Eraser"
        }
    }

    var systemImage: String {
        switch self {
        case .pen: "pencil.tip"
        case .eraser: "eraser"
        }
    }
}

/// User-selectable stroke sizes shared by Pencil and finger input.
enum DrawingWidth: String, CaseIterable, Identifiable {
    case thin
    case medium
    case thick

    var id: String { rawValue }

    var points: CGFloat {
        switch self {
        case .thin: 3
        case .medium: 8
        case .thick: 18
        }
    }

    var label: String {
        rawValue.capitalized
    }
}

/// A high-contrast palette that remains fast to scan during a timed turn.
enum DrawingColor: String, CaseIterable, Identifiable {
    case black
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case brown

    var id: String { rawValue }

    var label: String {
        rawValue.capitalized
    }

    var uiColor: UIColor {
        switch self {
        case .black: .black
        case .red: .systemRed
        case .orange: .systemOrange
        case .yellow: .systemYellow
        case .green: .systemGreen
        case .blue: .systemBlue
        case .purple: .systemPurple
        case .brown: .systemBrown
        }
    }

    var color: Color {
        Color(uiColor: uiColor)
    }
}

/// Complete local selection used to configure the PencilKit canvas.
struct DrawingToolSelection {
    var tool: DrawingTool
    var width: DrawingWidth
    var color: DrawingColor

    /// Creates the framework tool without exposing PencilKit to game rules.
    var pencilKitTool: any PKTool {
        switch tool {
        case .pen:
            PKInkingTool(.pen, color: color.uiColor, width: width.points)
        case .eraser:
            PKEraserTool(.vector)
        }
    }
}

