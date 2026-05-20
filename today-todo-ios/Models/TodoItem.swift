import Foundation

// Shared between the main app target and the widget extension target.
// No DateService dependency — callers supply createdAt and dayKey directly.
// Target membership: today-todo-ios ✓  TaskWidgetExtension ✓

struct TodoItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var completedAt: Date?
    let createdAt: Date
    let dayKey: String      // "yyyy-MM-dd" — buckets tasks by calendar day
    var expiresAt: Date?    // optional same-day expiry; always < end of createdAt day

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool  = false,
        completedAt: Date? = nil,
        createdAt: Date,
        dayKey: String,
        expiresAt: Date?   = nil
    ) {
        self.id          = id
        self.title       = title
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.createdAt   = createdAt
        self.dayKey      = dayKey
        self.expiresAt   = expiresAt
    }
}
