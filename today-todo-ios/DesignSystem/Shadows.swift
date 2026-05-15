import SwiftUI

// MARK: - Shadow level

enum ShadowLevel {
    case hairline   // Subtle edge definition on flat surfaces
    case raised     // Cards, row surfaces lifted from canvas
    case floating   // FAB, popover menus
    case sheet      // Bottom sheet — shadow projects upward
}

// MARK: - Modifier

/// Applies layered shadows matching the design token spec.
/// Values sourced from tokens.js (canonical over CONTEXT.md quick-reference).
struct TodayShadowModifier: ViewModifier {

    let level: ShadowLevel

    // rgba(28, 23, 20, …) — deep warm black
    private static let base = Color(red: 28/255, green: 23/255, blue: 20/255)

    func body(content: Content) -> some View {
        switch level {

        case .hairline:
            // 0 0 0 0.5px rgba(28,23,20,0.08) — thin border substitute
            content
                .shadow(color: Self.base.opacity(0.08), radius: 0.5, x: 0, y: 0)

        case .raised:
            // 0 1px 2px rgba(28,23,20,0.04), 0 4px 12px rgba(28,23,20,0.06)
            content
                .shadow(color: Self.base.opacity(0.04), radius: 1,  x: 0, y: 1)
                .shadow(color: Self.base.opacity(0.06), radius: 6,  x: 0, y: 4)

        case .floating:
            // 0 2px 6px rgba(28,23,20,0.06), 0 8px 24px rgba(28,23,20,0.10)
            content
                .shadow(color: Self.base.opacity(0.06), radius: 3,  x: 0, y: 2)
                .shadow(color: Self.base.opacity(0.10), radius: 12, x: 0, y: 8)

        case .sheet:
            // 0 -2px 12px rgba(28,23,20,0.04), 0 -8px 40px rgba(28,23,20,0.08)
            content
                .shadow(color: Self.base.opacity(0.04), radius: 6,  x: 0, y: -2)
                .shadow(color: Self.base.opacity(0.08), radius: 20, x: 0, y: -8)
        }
    }
}

// MARK: - View convenience

extension View {
    func shadowStyle(_ level: ShadowLevel) -> some View {
        modifier(TodayShadowModifier(level: level))
    }
}
