import SwiftUI

/// Animated check circle — stub. Full animation wired in Step 3.
struct CheckCircleView: View {

    let isCompleted: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.accent : Color.clear)
                .overlay(
                    Circle()
                        .stroke(isCompleted ? Color.accent : Color.inkQuaternary,
                                lineWidth: AppConstants.checkCircleStroke)
                )

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.4, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
    }
}
