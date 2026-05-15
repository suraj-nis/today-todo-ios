import CoreGraphics

// MARK: - Layout constants
//
// Strategy:
//   • Padding and gaps → Spacing.xs / sm / md / lg / xl / xxl directly in Views
//   • Component sizes  → base values here; Views wrap each in @ScaledMetric
//   • Row heights      → removed; SwiftUI native layout (padding + flexible frames)
//   • tabBarHeight and sheetCornerRadius are the only fixed values — they must
//     not scale with Dynamic Type.
//
// Usage pattern for @ScaledMetric:
//   @ScaledMetric(relativeTo: .body) private var circleSize = AppConstants.checkCircleSize

enum AppConstants {

    // MARK: Fixed — do NOT wrap in @ScaledMetric

    /// Visible tab bar content height. Safe-area inset below is handled by SwiftUI.
    static let tabBarHeight: CGFloat = 49

    /// Top corner radius of the add-task bottom sheet.
    static let sheetCornerRadius: CGFloat = 28

    // MARK: Component sizes — wrap each in @ScaledMetric at point of use

    /// Diameter of the task completion circle in the Today list.
    static let checkCircleSize: CGFloat = 24   // @ScaledMetric(relativeTo: .body)

    /// Stroke width of the unfilled check circle ring.
    static let checkCircleStroke: CGFloat = 1.5  // @ScaledMetric(relativeTo: .body)

    /// Diameter of the smaller unfilled circle used in the Archive list.
    static let archiveCheckCircleSize: CGFloat = 18  // @ScaledMetric(relativeTo: .footnote)

    /// Diameter of the floating action button.
    static let fabSize: CGFloat = 60  // @ScaledMetric(relativeTo: .body)

    /// Distance from the FAB's bottom edge to the bottom safe-area edge.
    /// Not in the 4pt spacing scale; kept here so it scales with the FAB.
    static let fabBottomPadding: CGFloat = 56  // @ScaledMetric(relativeTo: .body)

    /// Width of the custom drag grabber drawn at the top of the add-task sheet.
    static let sheetGrabberWidth: CGFloat = 36  // @ScaledMetric(relativeTo: .body)

    /// Height of the custom drag grabber.
    static let sheetGrabberHeight: CGFloat = 4   // @ScaledMetric(relativeTo: .body)

    /// Diameter of the pulsing accent dot shown beside expiry timestamps at sunset.
    /// Not in the 4pt spacing scale.
    static let expiryDotSize: CGFloat = 5  // @ScaledMetric(relativeTo: .caption)
}
