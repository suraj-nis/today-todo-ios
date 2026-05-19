import SwiftUI
import WidgetKit

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: TaskEntry

    // Group 1: incomplete with expiry — most urgent first
    // Group 2: incomplete without expiry — oldest first
    // Group 3: completed — most recently completed first
    private var sortedIncomplete: [TodoItem] {
        let withExpiry = entry.incompleteTasks
            .filter { $0.expiresAt != nil }
            .sorted { $0.expiresAt! < $1.expiresAt! }
        let withoutExpiry = entry.incompleteTasks
            .filter { $0.expiresAt == nil }
            .sorted { $0.createdAt < $1.createdAt }
        return withExpiry + withoutExpiry
    }

    private var sortedCompleted: [TodoItem] {
        entry.completedTasks
            .sorted { ($0.completedAt ?? $0.createdAt) > ($1.completedAt ?? $1.createdAt) }
    }

    // If more than 3 incomplete, show first 3 sorted incomplete + overflow label.
    private var showsOverflow: Bool { entry.incompleteCount > 3 }

    private var displayTasks: [TodoItem] {
        guard !showsOverflow else { return [] }
        return Array((sortedIncomplete + sortedCompleted).prefix(4))
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            leftColumn
            divider
            rightColumn
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.wBgBase)
    }

    // MARK: - Left column (mirrors SmallWidgetView layout)

    private var leftColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.dateKicker)
                .font(.custom("GeistMono-Regular", size: 9))
                .foregroundStyle(Color.wInkTert)
                .tracking(1.2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.trailing)

            Spacer()

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

            Text("\(entry.completedCount) / \(entry.totalCount) DONE")
                .font(.custom("GeistMono-Regular", size: 9))
                .foregroundStyle(Color.wAccent)
                .tracking(1.2)
        }
        .frame(width: 80)
    }

    // MARK: - Divider

    private var divider: some View {
        Rectangle()
            .fill(Color(red: 0xE8/255, green: 0xE0/255, blue: 0xD2/255))
            .frame(width: 0.5)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
    }

    // MARK: - Right column (task list)

    private var rightColumn: some View {
        VStack(alignment: .leading, spacing: 6) {
            if showsOverflow {
                ForEach(Array(sortedIncomplete.prefix(3))) { task in
                    taskRow(task)
                }
                Text("+\(entry.incompleteCount - 3) more")
                    .font(.custom("GeistMono-Regular", size: 9))
                    .foregroundStyle(Color.wInkTert)
                    .tracking(1.0)
            } else {
                ForEach(displayTasks) { task in
                    taskRow(task)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Task row

    @ViewBuilder
    private func taskRow(_ task: TodoItem) -> some View {
        let titleColor: Color = task.isCompleted ? Color.wInkTert : .black
        HStack(spacing: 6) {
            // Circle indicator
            ZStack {
                Circle()
                    .fill(task.isCompleted ? Color.wAccent : Color.clear)
                    .overlay(
                        Circle()
                            .stroke(
                                task.isCompleted ? Color.wAccent : Color.wInkTert,
                                lineWidth: 1
                            )
                    )
                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 6, weight: .bold))
                        .foregroundStyle(Color.white)
                }
            }
            .frame(width: 11, height: 11)

            // Title — flexible, truncates before expiry label
            Text(task.title)
                .font(.custom("Geist-Regular", size: 12))
                .foregroundStyle(titleColor)
                .tracking(-0.1)
                .lineLimit(1)
                .truncationMode(.tail)
                .strikethrough(task.isCompleted, color: titleColor)

            Spacer()

            // Expiry time — incomplete non-expired tasks only
            if !task.isCompleted, let exp = task.expiresAt {
                HStack(spacing: 3) {
                    Circle()
                        .fill(Color.wAccent)
                        .frame(width: 4, height: 4)
                    Text(formattedExpiry(exp))
                        .font(.custom("GeistMono-Regular", size: 8))
                        .foregroundStyle(Color.wAccent)
                        .tracking(0.8)
                }
            }
        }
    }

    private func formattedExpiry(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

// MARK: - Colour helpers (local — cannot use main-app DesignSystem)

private extension Color {
    static let wBgBase     = Color(red: 0xF2/255, green: 0xEE/255, blue: 0xE6/255)
    static let wInkPrimary = Color(red: 0x1C/255, green: 0x17/255, blue: 0x14/255)
    static let wInkSec     = Color(red: 0x5C/255, green: 0x54/255, blue: 0x4D/255)
    static let wInkTert    = Color(red: 0x9A/255, green: 0x90/255, blue: 0x87/255)
    static let wAccent     = Color(red: 0xC0/255, green: 0x53/255, blue: 0x2E/255)
}
