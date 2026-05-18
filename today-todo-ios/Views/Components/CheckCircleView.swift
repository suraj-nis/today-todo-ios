import SwiftUI

struct CheckCircleView: View {

    let isCompleted: Bool
    let isExpired: Bool
    let size: CGFloat
    var borderColor: Color = Color.inkTertiary

    var body: some View {
        ZStack {
            Circle()
                .fill(fillColor)
                .overlay(
                    Circle()
                        .stroke(strokeColor, lineWidth: AppConstants.checkCircleStroke)
                )

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.4, weight: .medium))
                    .foregroundStyle(Color.surfaceRaised)
            } else if isExpired {
                Image(systemName: "xmark")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(Color.white)
            }
        }
        .frame(width: size, height: size)
    }

    private var fillColor: Color {
        if isCompleted { return Color.inkPrimary }
        if isExpired   { return Color(red: 0, green: 0, blue: 0) }
        return Color.clear
    }

    private var strokeColor: Color {
        if isCompleted { return Color.inkPrimary }
        if isExpired   { return Color(red: 0, green: 0, blue: 0) }
        return borderColor
    }
}
