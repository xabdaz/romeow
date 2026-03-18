import CoreGraphics

// MARK: - Spacing Scale
/// 4-point based spacing scale for consistent layout
public enum Spacing {
    /// 2pt - Extra extra small spacing
    public static let xxSmall: CGFloat = 2

    /// 4pt - Extra small spacing
    public static let xSmall: CGFloat = 4

    /// 8pt - Small spacing
    public static let small: CGFloat = 8

    /// 12pt - Medium spacing
    public static let medium: CGFloat = 12

    /// 16pt - Large spacing
    public static let large: CGFloat = 16

    /// 20pt - Extra large spacing
    public static let xLarge: CGFloat = 20

    /// 24pt - Extra extra large spacing
    public static let xxLarge: CGFloat = 24

    /// 32pt - Huge spacing
    public static let huge: CGFloat = 32

    /// 40pt - Extra huge spacing
    public static let xHuge: CGFloat = 40

    /// 48pt - Extra extra huge spacing
    public static let xxHuge: CGFloat = 48
}

// MARK: - Corner Radius
public enum CornerRadius {
    /// 4pt - Small corner radius (badges, small buttons)
    public static let small: CGFloat = 4

    /// 6pt - Medium corner radius (buttons, inputs)
    public static let medium: CGFloat = 6

    /// 8pt - Large corner radius (cards, panels)
    public static let large: CGFloat = 8

    /// 10pt - Extra large corner radius (larger cards)
    public static let xLarge: CGFloat = 10

    /// 12pt - Extra extra large corner radius (modals, sheets)
    public static let xxLarge: CGFloat = 12

    /// 16pt - Huge corner radius (feature cards)
    public static let huge: CGFloat = 16
}

// MARK: - Icon Sizes
public enum IconSize {
    /// 12pt - Small icon size
    public static let small: CGFloat = 12

    /// 14pt - Small medium icon size
    public static let smallMedium: CGFloat = 14

    /// 16pt - Medium icon size (default)
    public static let medium: CGFloat = 16

    /// 20pt - Large icon size
    public static let large: CGFloat = 20

    /// 24pt - Extra large icon size
    public static let xLarge: CGFloat = 24

    /// 28pt - Extra extra large icon size
    public static let xxLarge: CGFloat = 28

    /// 32pt - Huge icon size
    public static let huge: CGFloat = 32

    /// 44pt - Extra huge icon size (toolbar)
    public static let xHuge: CGFloat = 44
}

// MARK: - Button Sizes
public enum ButtonSize {
    /// 28pt - Small button height
    public static let small: CGFloat = 28

    /// 32pt - Medium button height
    public static let medium: CGFloat = 32

    /// 44pt - Large button height
    public static let large: CGFloat = 44
}

// MARK: - Frame Sizes
public enum FrameSize {
    /// 44pt - Minimum tappable area
    public static let minTappable: CGFloat = 44

    /// 56pt - Toolbar height
    public static let toolbar: CGFloat = 56

    /// 64pt - Header height
    public static let header: CGFloat = 64

    /// 200pt - Sidebar minimum width
    public static let sidebarMin: CGFloat = 200

    /// 300pt - Sidebar default width
    public static let sidebarDefault: CGFloat = 300

    /// 400pt - Detail minimum width
    public static let detailMin: CGFloat = 400
}

// MARK: - Border Width
public enum BorderWidth {
    /// 0.5pt - Hairline border
    public static let hairline: CGFloat = 0.5

    /// 1pt - Thin border
    public static let thin: CGFloat = 1

    /// 2pt - Medium border
    public static let medium: CGFloat = 2
}
