import SwiftUI

// MARK: - Badge Style
public enum BadgeStyle {
    case filled
    case outlined
    case subtle
}

// MARK: - View Modifiers
extension View {

    // MARK: - Badge Modifier
    /// Applies badge styling to a view
    /// - Parameters:
    ///   - color: The color of the badge
    ///   - style: The badge style (filled, outlined, subtle)
    public func rmeBadge(
        color: Color,
        style: BadgeStyle = .subtle
    ) -> some View {
        self.modifier(BadgeModifier(color: color, style: style))
    }

    // MARK: - Selection Background
    /// Applies selection background styling
    /// - Parameter isSelected: Whether the item is selected
    public func rmeSelectionBackground(isSelected: Bool) -> some View {
        self.modifier(SelectionBackgroundModifier(isSelected: isSelected))
    }

    // MARK: - Card Container
    /// Applies card container styling
    public func rmeCard() -> some View {
        self.modifier(CardModifier())
    }

    // MARK: - Input Container
    /// Applies input field container styling
    public func rmeInput() -> some View {
        self.modifier(InputModifier())
    }

    // MARK: - Section Header
    /// Applies section header styling
    public func rmeSectionHeader() -> some View {
        self.modifier(SectionHeaderModifier())
    }
}

// MARK: - Badge Modifier
struct BadgeModifier: ViewModifier {
    let color: Color
    let style: BadgeStyle

    func body(content: Content) -> some View {
        content
            .font(.rmeCaptionBold)
            .foregroundStyle(foregroundColor)
            .frame(minWidth: 32)
            .padding(.vertical, Spacing.xxSmall)
            .padding(.horizontal, Spacing.xSmall)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .stroke(borderColor, lineWidth: BorderWidth.thin)
            )
    }

    private var foregroundColor: Color {
        switch style {
        case .filled:
            return .white
        case .outlined, .subtle:
            return color
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .filled:
            return color
        case .outlined:
            return Color.clear
        case .subtle:
            return color.opacity(0.15)
        }
    }

    private var borderColor: Color {
        switch style {
        case .filled:
            return Color.clear
        case .outlined:
            return color
        case .subtle:
            return Color.clear
        }
    }
}

// MARK: - Selection Background Modifier
struct SelectionBackgroundModifier: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(isSelected ? Color.rmeActiveBackground : Color.clear)
            )
    }
}

// MARK: - Card Modifier
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .fill(Color.rmeSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .stroke(Color.rmeBorder, lineWidth: BorderWidth.thin)
            )
    }
}

// MARK: - Input Modifier
struct InputModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.xSmall)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.rmeTextBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(Color.rmeBorder, lineWidth: BorderWidth.thin)
            )
    }
}

// MARK: - Section Header Modifier
struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.rmeFootnoteSemibold)
            .foregroundStyle(Color.rmeSecondaryText)
            .textCase(.uppercase)
    }
}

// MARK: - Convenience Extensions for HTTP Method Badges
extension View {
    /// Applies HTTP method badge styling
    /// - Parameter method: The HTTP method
    public func rmeHTTPMethodBadge(_ method: HTTPMethod) -> some View {
        self.rmeBadge(color: .httpMethod(method), style: .subtle)
    }
}
