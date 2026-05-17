import SwiftUI

struct TaskRowView: View {

    let task: TodoItem
    let timeOfDay: TimeOfDay
    let onToggle: () -> Void

    @State private var strikethroughProgress: CGFloat = 0
    @State private var strikethroughColor: Color = .inkTertiary
    @State private var textWidth: CGFloat = 0
    @ScaledMetric(relativeTo: .body) private var circleSize = AppConstants.checkCircleSize

    private var expiryColor: Color {
        timeOfDay == .evening ? Color.accent : Color.inkTertiary
    }

    private var titleColor: Color {
        guard task.isCompleted else { return Color.inkPrimary }
        return timeOfDay == .evening ? Color(hex: "#9C5851") : Color.inkTertiary
    }

    private var circleBorderColor: Color {
        !task.isCompleted && timeOfDay == .evening ? Color(hex: "#9C5851") : Color.inkTertiary
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .center, spacing: Spacing.md) {
                CheckCircleView(isCompleted: task.isCompleted, size: circleSize,
                                borderColor: circleBorderColor)

                VStack(alignment: .leading, spacing: Spacing.xs) {
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

                    if let exp = task.expiresAt {
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
            .padding(.vertical, Spacing.md)
            .padding(.horizontal, Spacing.xxl)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(task.title)
        .accessibilityValue(task.isCompleted ? "checked" : "unchecked")
        .accessibilityAddTraits(.isButton)
        .onAppear {
            if task.isCompleted {
                strikethroughColor   = timeOfDay == .evening ? Color(hex: "#9C5851") : Color.inkTertiary
                strikethroughProgress = 1
            }
        }
        .onChange(of: task.isCompleted) { _, completed in
            if completed {
                strikethroughColor = timeOfDay == .evening ? Color(hex: "#9C5851") : Color.inkTertiary
            }
            withAnimation(completed ? .strikethrough : .paper(duration: 0.480)) {
                strikethroughProgress = completed ? 1 : 0
            }
        }
    }
}
