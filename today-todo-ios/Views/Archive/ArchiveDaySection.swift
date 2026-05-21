import SwiftUI

// MARK: - Task display state

private enum ArchiveTaskKind {
    case completed
    case expired    // had expiresAt set, day ended without completion
    case incomplete // no expiresAt set, day ended without completion
}

// MARK: - Day section

struct ArchiveDaySection: View {

    let day: ArchivedDay
    let colors: ArchiveColorScheme
    let onDelete: () -> Void

    @State private var showingDeleteConfirm = false
    @ScaledMetric(relativeTo: .footnote) private var circleSize = AppConstants.archiveCheckCircleSize

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            dayHeader

            ForEach(displayTasks, id: \.task.id) { item in
                taskRow(task: item.task, kind: item.kind)
            }

            HStack {
                Spacer()
                deleteButton
            }
        }
        .padding(.bottom, Spacing.s3)
        .alert("Remove this day?", isPresented: $showingDeleteConfirm) {
            Button("Remove", role: .destructive) { onDelete() }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Display name

    /// Computes the human-friendly label at render time so "Yesterday" is always
    /// accurate and never a stale value cached in the model.
    private var displayDayName: String {
        Calendar.current.isDateInYesterday(day.date) ? "Yesterday" : day.dayName
    }

    // MARK: - Delete button

    private var deleteButton: some View {
        Button {
            showingDeleteConfirm = true
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 16))
                .foregroundStyle(Color.inkPrimary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Delete \(displayDayName)")
        .padding(.top, Spacing.xs)
        .padding(.bottom, Spacing.sm)
    }

    // MARK: - Day header

    private var dayHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(displayDayName)
                .font(.archiveDayName)
                .foregroundStyle(Color.archiveInkDark)
                .tracking(-0.4)

            Spacer()

            Text(day.dateLabel)
                .font(.todayCaption)
                .foregroundStyle(colors.dateLabelColor)
                .tracking(1.4)
        }
    }

    // MARK: - Display order: completed → incomplete → expired

    private var displayTasks: [(task: TodoItem, kind: ArchiveTaskKind)] {
        let completed  = day.completedTasks.map  { (task: $0, kind: ArchiveTaskKind.completed) }
        let incomplete = day.incompleteTasks.map { (task: $0, kind: ArchiveTaskKind.incomplete) }
        let expired    = day.expiredTasks.map    { (task: $0, kind: ArchiveTaskKind.expired)   }
        return completed + incomplete + expired
    }

    // MARK: - Task row router

    @ViewBuilder
    private func taskRow(task: TodoItem, kind: ArchiveTaskKind) -> some View {
        switch kind {
        case .completed:
            completedRow(task)
        case .expired, .incomplete:
            mutedRow(task, showExpiredLabel: kind == .expired)
        }
    }

    // MARK: - Completed row

    private func completedRow(_ task: TodoItem) -> some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            completedCircle
            Text(task.title)
                .font(.archiveTaskTitle)
                .foregroundStyle(Color.archiveInkWarm)
                .strikethrough(true, color: Color.archiveInkWarm)
                .tracking(0)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, Spacing.sm)
        .accessibilityLabel("\(task.title), completed")
    }

    private var completedCircle: some View {
        ZStack {
            Circle()
                .fill(Color.archiveCircleFill)
                .frame(width: circleSize, height: circleSize)
            Image(systemName: "checkmark")
                .font(.system(size: circleSize * 0.5, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: circleSize, height: circleSize)
    }

    // MARK: - Expired / incomplete row

    private func mutedRow(_ task: TodoItem, showExpiredLabel: Bool) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Circle()
                .fill(Color.clear)
                .overlay(
                    Circle()
                        .stroke(colors.circleBorderColor, lineWidth: AppConstants.checkCircleStroke)
                )
                .frame(width: circleSize, height: circleSize)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.archiveTaskTitle)
                    .foregroundStyle(colors.mutedTitleColor)
                    .tracking(0)
                    .fixedSize(horizontal: false, vertical: true)

                if showExpiredLabel {
                    Text("— EXPIRED UNTOUCHED")
                        .font(.archiveExpiredLabel)
                        .foregroundStyle(Color.warning)
                        .tracking(1.4)
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, Spacing.sm)
        .accessibilityLabel(
            showExpiredLabel
                ? "\(task.title), expired untouched"
                : "\(task.title), not finished"
        )
    }
}

// MARK: - Preview

#Preview("Morning") {
    ZStack {
        LinearGradient.todayMorning.ignoresSafeArea()
        ScrollView {
            ArchiveDaySection(
                day: ArchivedDay(
                    id: UUID(),
                    dayName: "Monday",
                    date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                    dateLabel: "MAY 18",
                    tasks: [
                        TodoItem(title: "Morning pages",
                                 isCompleted: true, completedAt: Date(),
                                 createdAt: Date(), dayKey: "2026-05-18"),
                        TodoItem(title: "Water the lemon tree",
                                 isCompleted: false,
                                 createdAt: Date(), dayKey: "2026-05-18"),
                        TodoItem(title: "Submit the form before noon",
                                 isCompleted: false,
                                 createdAt: Date(), dayKey: "2026-05-18",
                                 expiresAt: Date()),
                    ]
                ),
                colors: .make(for: .morning),
                onDelete: {}
            )
            .padding(.horizontal, Spacing.lg)
        }
    }
}

#Preview("Evening") {
    ZStack {
        LinearGradient.todaySunset.ignoresSafeArea()
        ScrollView {
            ArchiveDaySection(
                day: ArchivedDay(
                    id: UUID(),
                    dayName: "Monday",
                    date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                    dateLabel: "MAY 18",
                    tasks: [
                        TodoItem(title: "Morning pages",
                                 isCompleted: true, completedAt: Date(),
                                 createdAt: Date(), dayKey: "2026-05-18"),
                        TodoItem(title: "Water the lemon tree",
                                 isCompleted: false,
                                 createdAt: Date(), dayKey: "2026-05-18"),
                        TodoItem(title: "Submit the form before noon",
                                 isCompleted: false,
                                 createdAt: Date(), dayKey: "2026-05-18",
                                 expiresAt: Date()),
                    ]
                ),
                colors: .make(for: .evening),
                onDelete: {}
            )
            .padding(.horizontal, Spacing.lg)
        }
    }
}
