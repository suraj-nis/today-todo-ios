import Foundation

// MARK: - ArchivedDay

/// One past calendar day shown in the Archive tab.
/// Main app target only — not compiled into the widget.
struct ArchivedDay: Identifiable, Codable {
    let id: UUID
    let dayName: String     // "Yesterday", "Monday", etc.
    let date: Date          // The actual date for this day
    let dateLabel: String   // "MAY 13" — uppercase, pre-formatted
    let tasks: [TodoItem]   // All tasks stored for this day

    // MARK: - Derived task groups

    /// Tasks the user finished before the day ended.
    var completedTasks: [TodoItem] {
        tasks.filter { $0.isCompleted }
    }

    /// Incomplete tasks that had a same-day expiry time set.
    /// Since the day is over every expiresAt has passed.
    var expiredTasks: [TodoItem] {
        tasks.filter { !$0.isCompleted && $0.expiresAt != nil }
    }

    /// Incomplete tasks with no expiry — the day simply ended before they were done.
    var incompleteTasks: [TodoItem] {
        tasks.filter { !$0.isCompleted && $0.expiresAt == nil }
    }

    // MARK: - Convenience counts

    var completedCount: Int  { completedTasks.count }
    var totalCount: Int      { tasks.count }
}
