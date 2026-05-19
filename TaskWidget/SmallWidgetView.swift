import SwiftUI
import WidgetKit

// MARK: - Colour helpers (local — cannot use main-app DesignSystem)

private extension Color {
    /// Warm paper background — bgBase light (#F2EEE6)
    static let wBgBase      = Color(red: 0xF2/255, green: 0xEE/255, blue: 0xE6/255)
    /// Deep ink primary (#1C1714)
    static let wInkPrimary  = Color(red: 0x1C/255, green: 0x17/255, blue: 0x14/255)
    /// Secondary ink (#5C544D)
    static let wInkSec      = Color(red: 0x5C/255, green: 0x54/255, blue: 0x4D/255)
    /// Tertiary ink / muted (#9A9087)
    static let wInkTert     = Color(red: 0x9A/255, green: 0x90/255, blue: 0x87/255)
    /// Terracotta accent (#C0532E)
    static let wAccent      = Color(red: 0xC0/255, green: 0x53/255, blue: 0x2E/255)
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: TaskEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Date kicker ────────────────────────────────────────────────
            Text(entry.dateKicker)
                .font(.custom("GeistMono-Regular", size: 9))
                .foregroundStyle(Color.wInkTert)
                .tracking(1.2)

            Spacer()

            // ── Incomplete count + "left" ──────────────────────────────────
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(entry.incompleteCount)")
                    .font(.custom("Fraunces144pt-Light", size: 56))
                    .foregroundStyle(Color.wInkPrimary)
                    .tracking(-1.5)

                Text("left")
                    .font(.custom("Fraunces144pt-LightItalic", size: 18))
                    .foregroundStyle(Color.wInkSec)
                    .tracking(0)
            }

            Spacer()

            // ── Progress label ─────────────────────────────────────────────
            Text("\(entry.completedCount) / \(entry.totalCount) DONE")
                .font(.custom("GeistMono-Regular", size: 9))
                .foregroundStyle(Color.wAccent)
                .tracking(1.2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.wBgBase)
    }
}
