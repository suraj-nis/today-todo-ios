import SwiftUI

struct TaskRowView: View {

    let task: TodoItem
    let timeOfDay: TimeOfDay
    let isExpired: Bool
    let onToggle: () -> Void

    @State private var strikethroughProgress: CGFloat = 0
    @State private var strikethroughColor: Color = .inkTertiary
    @State private var textWidth: CGFloat = 0
    @ScaledMetric(relativeTo: .body) private var circleSize = AppConstants.checkCircleSize

    // Muted color matching completed style — shared by expired and completed states.
    private var mutedTitleColor: Color {
        timeOfDay == .evening ? Color(hex: "#9C5851") : Color.inkTertiary
    }

    private var titleColor: Color {
        if isExpired || task.isCompleted { return mutedTitleColor }
        return Color.inkPrimary
    }

    private var expiryColor: Color {
        if isExpired { return Color.inkTertiary }
        return timeOfDay == .evening ? Color.accent : Color.inkTertiary
    }

    private var circleBorderColor: Color {
        if isExpired { return Color.inkPrimary }
        return !task.isCompleted && timeOfDay == .evening ? Color(hex: "#9C5851") : Color.inkTertiary
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .center, spacing: Spacing.md) {
                CheckCircleView(isCompleted: task.isCompleted, isExpired: isExpired,
                                size: circleSize, borderColor: circleBorderColor)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    titleText
                    expiryMeta
                }
            }
            .padding(.vertical, Spacing.md)
            .padding(.horizontal, Spacing.xxl)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .allowsHitTesting(!isExpired)
        .accessibilityLabel(task.title)
        .accessibilityValue(task.isCompleted ? "checked" : "unchecked")
        .accessibilityAddTraits(.isButton)
        .onAppear {
            if isExpired {
                strikethroughColor    = mutedTitleColor
                strikethroughProgress = 1
            } else if task.isCompleted {
                strikethroughColor    = mutedTitleColor
                strikethroughProgress = 1
            }
        }
        .onChange(of: task.isCompleted) { _, completed in
            if completed {
                strikethroughColor = mutedTitleColor
            }
            withAnimation(completed ? .strikethrough : .paper(duration: 0.480)) {
                strikethroughProgress = completed ? 1 : 0
            }
        }
    }

    // MARK: - Subviews

    private var titleText: some View {
        Text(task.title)
            .todayStyle(.body)
            .tracking(-0.2)
            .foregroundStyle(titleColor)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { textWidth = geo.size.width }
                        .onChange(of: geo.size.width) { _, w in textWidth = w }
                }
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .leading) {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0.5))
                    path.addLine(to: CGPoint(x: textWidth, y: 0.5))
                }
                .trim(from: 0, to: strikethroughProgress)
                .stroke(strikethroughColor, lineWidth: 1)
                .frame(width: textWidth, height: 1)
            }
    }

    private var expiredLabelColor: Color {
        timeOfDay == .evening ? Color(hex: "#9C5851") : Color.inkTertiary
    }

    @ViewBuilder
    private var expiryMeta: some View {
        if let exp = task.expiresAt {
            if isExpired {
                HStack(spacing: Spacing.xs) {
                    Circle()
                        .fill(expiredLabelColor)
                        .frame(width: AppConstants.expiryDotSize,
                               height: AppConstants.expiryDotSize)
                    Text("Not finished in time")
                        .todayStyle(.caption)
                        .foregroundStyle(expiredLabelColor)
                }
            } else {
                HStack(spacing: Spacing.xs) {
                    Circle()
                        .fill(expiryColor)
                        .frame(width: AppConstants.expiryDotSize,
                               height: AppConstants.expiryDotSize)
                    Text("expires \(exp, style: .time)")
                        .todayStyle(.caption)
                        .foregroundStyle(expiryColor)
                }
            }
        }
    }
}
