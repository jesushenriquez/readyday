import SwiftUI

extension Font {

    // MARK: - Display

    static let rdDisplayLarge = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let rdDisplayMedium = Font.system(.title, design: .rounded, weight: .bold)

    // MARK: - Heading

    static let rdHeadingLarge = Font.system(.title2, design: .rounded, weight: .semibold)
    static let rdHeadingMedium = Font.system(.title3, design: .rounded, weight: .semibold)
    static let rdHeadingSmall = Font.system(.headline, design: .rounded, weight: .semibold)

    // MARK: - Body

    static let rdBodyLarge = Font.system(.body, design: .rounded)
    static let rdBodyMedium = Font.system(.callout, design: .rounded)
    static let rdBodySmall = Font.system(.subheadline, design: .rounded)

    // MARK: - Caption

    static let rdCaptionLarge = Font.system(.footnote, design: .rounded)
    static let rdCaptionSmall = Font.system(.caption2, design: .rounded)

    // MARK: - Data (standard SF Pro for precision)

    static let rdDataLarge = Font.system(size: 48, weight: .bold, design: .default)
    static let rdDataMedium = Font.system(size: 24, weight: .semibold, design: .default)
    static let rdDataSmall = Font.system(size: 14, weight: .medium, design: .monospaced)
}
