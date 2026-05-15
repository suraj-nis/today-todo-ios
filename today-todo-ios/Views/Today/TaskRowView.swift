import SwiftUI

/// Single task row — stub. Completion animation, strikethrough, and expiry
/// meta wired in Step 3.
struct TaskRowView: View {

    let task: TodoItem
    let onToggle: () -> Void

    @ScaledMetric(relativeTo: .body) private var circleSize = AppConstants.checkCircleSize

    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .center, spacing: Spacing.md) {
                CheckCircleView(isCompleted: task.isCompleted, size: circleSize)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(task.title)
                        .todayStyle(.body)
                        .foregroundStyle(task.isCompleted ? Color.inkTertiary : Color.inkPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let exp = task.expiresAt {
                        Text("expires \(exp, style: .time)")
                            .todayStyle(.caption)
                            .foregroundStyle(Color.inkTertiary)
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
    }
}
