import SwiftUI

// MARK: - HTTP Method Colors
extension Color {
    /// Returns the color associated with an HTTP method
    public static func httpMethod(_ method: HTTPMethod) -> Color {
        switch method {
        case .get:
            return .blue
        case .post:
            return .green
        case .put:
            return .orange
        case .patch:
            return .purple
        case .delete:
            return .red
        case .head, .options:
            return .gray
        }
    }
}

// MARK: - Status Colors
extension Color {
    /// Color for success states (200s, completed actions)
    public static let rmeSuccess = Color.green

    /// Color for error states (400s, 500s, failures)
    public static let rmeError = Color.red

    /// Color for warning states (300s, caution)
    public static let rmeWarning = Color.orange

    /// Color for informational states
    public static let rmeInfo = Color.blue
}

// MARK: - Neutral Text Colors
extension Color {
    /// Primary text color - adapts to light/dark mode
    public static let rmePrimaryText = Color.primary

    /// Secondary text color - less emphasis
    public static let rmeSecondaryText = Color.secondary

    /// Tertiary text color - subtle text
    public static var rmeTertiaryText: Color {
        Color.secondary.opacity(0.7)
    }

    /// Quaternary text color - very subtle text
    public static var rmeQuaternaryText: Color {
        Color.secondary.opacity(0.5)
    }
}

// MARK: - Background Colors
extension Color {
    /// Control background color (text fields, buttons)
    public static var rmeSurface: Color {
        Color(NSColor.controlBackgroundColor)
    }

    /// Window background color
    public static var rmeWindowBackground: Color {
        Color(NSColor.windowBackgroundColor)
    }

    /// Text background color
    public static var rmeTextBackground: Color {
        Color(NSColor.textBackgroundColor)
    }

    /// Under page background color (sidebar, etc.)
    public static var rmeUnderPageBackground: Color {
        Color(NSColor.underPageBackgroundColor)
    }
}

// MARK: - Semantic Colors
extension Color {
    /// Accent color with opacity for selection backgrounds
    public static var rmeSelectionBackground: Color {
        Color.accentColor.opacity(0.1)
    }

    /// Accent color with higher opacity for active states
    public static var rmeActiveBackground: Color {
        Color.accentColor.opacity(0.15)
    }

    /// Divider/separator color
    public static var rmeDivider: Color {
        Color.gray.opacity(0.2)
    }

    /// Border color for inputs and cards
    public static var rmeBorder: Color {
        Color.gray.opacity(0.3)
    }

    /// Placeholder text color
    public static var rmePlaceholder: Color {
        Color.gray.opacity(0.5)
    }
}

// MARK: - HTTP Status Code Colors
extension Color {
    /// Returns the color associated with an HTTP status code
    public static func httpStatusCode(_ code: Int) -> Color {
        switch code {
        case 200..<300:
            return .rmeSuccess
        case 300..<400:
            return .rmeWarning
        case 400..<500:
            return .rmeError
        case 500..<600:
            return .rmeError
        default:
            return .gray
        }
    }
}
