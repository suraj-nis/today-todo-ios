import SwiftUI

/// Animated check circle — stub. Full animation wired in Step 3.
struct CheckCircleView: View {

    let isCompleted: Bool
    let size: CGFloat
    var borderColor: Color = Color.inkTertiary

    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.inkPrimary : Color.clear)
                .overlay(
                    Circle()
                        .stroke(isCompleted ? Color.inkPrimary : borderColor,
                                lineWidth: AppConstants.checkCircleStroke)
                )

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.4, weight: .medium))
                    .foregroundStyle(Color.surfaceRaised)
            }
        }
        .frame(width: size, height: size)
    }
}
