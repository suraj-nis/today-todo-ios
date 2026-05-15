import SwiftUI

// MARK: - Private helpers

private extension UIColor {
    convenience init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(
            red:   CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >>  8) & 0xFF) / 255,
            blue:  CGFloat( rgb        & 0xFF) / 255,
            alpha: 1
        )
    }
}

fileprivate extension Color {
    init(light: String, dark: String) {
        self.init(UIColor {
            $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

// MARK: - Semantic colors

extension Color {

    // Surfaces — warm off-white paper hierarchy
    static let bgBase        = Color(light: "#F2EEE6", dark: "#14110E")
    static let bgCanvas      = Color(light: "#F7F3EB", dark: "#1A1612")
    static let surface       = Color(light: "#FBF8F2", dark: "#221D18")
    static let surfaceRaised = Color(light: "#FFFFFF",  dark: "#2C2620")

    // Ink — deep warm text hierarchy
    static let inkPrimary    = Color(light: "#1C1714", dark: "#F0EBE2")
    static let inkSecondary  = Color(light: "#5C544D", dark: "#B0A89E")
    static let inkTertiary   = Color(light: "#9A9087", dark: "#7A7268")
    static let inkQuaternary = Color(light: "#C5BCB1", dark: "#4A443E")

    // Accent — terracotta
    static let accent        = Color(light: "#C0532E", dark: "#D86A47")
    static let accentPressed = Color(light: "#A8431F", dark: "#B85633")
    static let accentSoft    = Color(light: "#F5DCCB", dark: "#3A2218")

    // Semantic
    static let destructive   = Color(light: "#A8312A", dark: "#D85249")
    static let success       = Color(light: "#5B7553", dark: "#7A9572")
    static let warning       = Color(light: "#B8893A", dark: "#D4A85E")

    // Lines
    static let divider       = Color(light: "#E8E0D2", dark: "#2E2823")
    static let dividerStrong = Color(light: "#D8CFC0", dark: "#3A332C")

    // Time-of-day gradient seeds (used as solid fallbacks and in stops below)
    static let morningGlow   = Color(light: "#FBDFC4", dark: "#3E2A1E")
    static let middayCool    = Color(light: "#E9EEF1", dark: "#1F2528")
    static let sunsetTop     = Color(light: "#DC7A72", dark: "#5A2620")
    static let sunsetMid     = Color(light: "#EFA689", dark: "#6E3A2C")
    static let sunsetBot     = Color(light: "#F2DCC4", dark: "#3A2A20")
}

// MARK: - Time-of-day gradients

extension LinearGradient {

    /// Dawn apricot sky fading to warm canvas — shown 6 am–12 pm.
    static let todayMorning = LinearGradient(
        stops: [
            .init(color: Color(light: "#FBDFC4", dark: "#3E2A1E"), location: 0.00),
            .init(color: Color(light: "#FAE7D2", dark: "#3A2820"), location: 0.14),
            .init(color: Color(light: "#F7ECDB", dark: "#2E2318"), location: 0.30),
            .init(color: Color(light: "#F5EEE0", dark: "#231C14"), location: 0.55),
            .init(color: Color(light: "#F2EEE6", dark: "#14110E"), location: 0.85),
        ],
        startPoint: .top, endPoint: .bottom
    )

    /// Pale cool sky easing to warm neutral — shown 12 pm–5 pm.
    static let todayMidday = LinearGradient(
        stops: [
            .init(color: Color(light: "#E9EEF1", dark: "#1F2528"), location: 0.00),
            .init(color: Color(light: "#EFF1EE", dark: "#222523"), location: 0.20),
            .init(color: Color(light: "#F3F2EB", dark: "#1E201C"), location: 0.45),
            .init(color: Color(light: "#F4EFE3", dark: "#1A1814"), location: 0.75),
            .init(color: Color(light: "#F2EEE6", dark: "#14110E"), location: 1.00),
        ],
        startPoint: .top, endPoint: .bottom
    )

    /// Deep rose sky burning down to warm canvas — shown after 11 pm trigger.
    static let todaySunset = LinearGradient(
        stops: [
            .init(color: Color(light: "#DC7A72", dark: "#5A2620"), location: 0.00),
            .init(color: Color(light: "#E78F7C", dark: "#62301E"), location: 0.11),
            .init(color: Color(light: "#EFA689", dark: "#6E3A2C"), location: 0.22),
            .init(color: Color(light: "#F4BB9C", dark: "#583020"), location: 0.33),
            .init(color: Color(light: "#F5CFB2", dark: "#48281A"), location: 0.45),
            .init(color: Color(light: "#F2DCC4", dark: "#3A2A20"), location: 0.60),
            .init(color: Color(light: "#F2E5D2", dark: "#2A1E18"), location: 0.75),
            .init(color: Color(light: "#F2EEE6", dark: "#14110E"), location: 0.90),
        ],
        startPoint: .top, endPoint: .bottom
    )
}

// MARK: - Tab bar frosted gradient

extension Color {
    /// The frosted glass fade applied above the tab bar on all time-of-day backgrounds.
    static let tabBarFrost = Color(light: "#F7F3EB", dark: "#1A1612")
}
