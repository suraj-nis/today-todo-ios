import SwiftUI

struct EmptyStateView: View {

    private static let promptColor   = Color(red: 0x6b/255.0, green: 0x4a/255.0, blue: 0x30/255.0)
    private static let dividerColor  = Color(red: 0xd4/255.0, green: 0xc2/255.0, blue: 0xa8/255.0)
    private static let footnoteColor = Color(red: 0xa0/255.0, green: 0x85/255.0, blue: 0x68/255.0)

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 10) {
                Text("What matters today?")
                    .todayStyle(.emptyPrompt)
                    .foregroundStyle(Self.promptColor)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 240)

                Self.dividerColor
                    .frame(width: 24, height: 1)
                    .padding(.top, Spacing.md)

                Text("Tap below to write your first thing.\nTasks only live for today.")
                    .todayStyle(.emptyFootnote)
                    .foregroundStyle(Self.footnoteColor)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 220)
                    .padding(.top, Spacing.md)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient.todayMorning.ignoresSafeArea()
        EmptyStateView()
            .frame(height: 500)
    }
}
