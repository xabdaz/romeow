import SwiftUI

// MARK: - Typography Scale
extension Font {

    // MARK: - Caption (9pt)
    /// Caption font - for small labels and badges
    public static let rmeCaption = Font.system(size: 9, weight: .medium)

    /// Caption bold - for emphasized small text
    public static let rmeCaptionBold = Font.system(size: 9, weight: .bold)

    // MARK: - Footnote (11pt)
    /// Footnote font - for secondary information
    public static let rmeFootnote = Font.system(size: 11, weight: .regular)

    /// Footnote medium - for emphasized secondary text
    public static let rmeFootnoteMedium = Font.system(size: 11, weight: .medium)

    /// Footnote semibold - for section labels
    public static let rmeFootnoteSemibold = Font.system(size: 11, weight: .semibold)

    // MARK: - Subheadline (12pt)
    /// Subheadline font - for small buttons and tertiary text
    public static let rmeSubheadline = Font.system(size: 12, weight: .regular)

    /// Subheadline medium - for emphasized subheadline
    public static let rmeSubheadlineMedium = Font.system(size: 12, weight: .medium)

    // MARK: - Body (13pt)
    /// Body font - primary reading text
    public static let rmeBody = Font.system(size: 13, weight: .regular)

    /// Body medium - for emphasized body text
    public static let rmeBodyMedium = Font.system(size: 13, weight: .medium)

    /// Body semibold - for navigation items
    public static let rmeBodySemibold = Font.system(size: 13, weight: .semibold)

    // MARK: - Callout (14pt)
    /// Callout font - for emphasized content
    public static let rmeCallout = Font.system(size: 14, weight: .regular)

    /// Callout medium - for emphasized callout
    public static let rmeCalloutMedium = Font.system(size: 14, weight: .medium)

    /// Callout semibold - for buttons and labels
    public static let rmeCalloutSemibold = Font.system(size: 14, weight: .semibold)

    /// Callout bold - for emphasized labels
    public static let rmeCalloutBold = Font.system(size: 14, weight: .bold)

    // MARK: - Headline (16pt)
    /// Headline font - for section headers
    public static let rmeHeadline = Font.system(size: 16, weight: .semibold)

    /// Headline bold - for prominent headers
    public static let rmeHeadlineBold = Font.system(size: 16, weight: .bold)

    // MARK: - Title 3 (18pt)
    /// Title 3 font - for card titles and subsections
    public static let rmeTitle3 = Font.system(size: 18, weight: .regular)

    /// Title 3 semibold - for emphasized card titles
    public static let rmeTitle3Semibold = Font.system(size: 18, weight: .semibold)

    // MARK: - Title 2 (20pt)
    /// Title 2 font - for panel titles and large icons
    public static let rmeTitle2 = Font.system(size: 20, weight: .regular)

    /// Title 2 medium - for emphasized panel titles
    public static let rmeTitle2Medium = Font.system(size: 20, weight: .medium)

    /// Title 2 semibold - for prominent panel titles
    public static let rmeTitle2Semibold = Font.system(size: 20, weight: .semibold)

    // MARK: - Title (22pt)
    /// Title font - for feature icons and main headers
    public static let rmeTitle = Font.system(size: 22, weight: .regular)

    /// Title medium - for emphasized titles
    public static let rmeTitleMedium = Font.system(size: 22, weight: .medium)

    /// Title semibold - for prominent feature headers
    public static let rmeTitleSemibold = Font.system(size: 22, weight: .semibold)

    // MARK: - Monospace Fonts (for code)
    /// Monospaced body font - for code display
    public static let rmeMonospaced = Font.system(size: 13, design: .monospaced)

    /// Monospaced caption font - for small code snippets
    public static let rmeMonospacedCaption = Font.system(size: 11, design: .monospaced)

    /// Monospaced callout font - for emphasized code
    public static let rmeMonospacedCallout = Font.system(size: 14, design: .monospaced)
}
