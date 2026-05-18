import Foundation

struct TodoItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var completedAt: Date?  // set when marked complete, cleared on uncheck
    let createdAt: Date
    let dayKey: String      // "yyyy-MM-dd" — buckets tasks by calendar day
    var expiresAt: Date?    // optional same-day expiry; always < end of createdAt day

    /// Convenience init — caller provides only the task content.
    /// Identity, completion, and timestamp are always generated here.
    init(title: String, expiresAt: Date? = nil, dateService: DateServiceProtocol = LiveDateService()) {
        self.id          = UUID()
        self.title       = title
        self.isCompleted = false
        self.completedAt = nil
        self.createdAt   = dateService.now
        self.dayKey      = dateService.todayKey
        self.expiresAt   = expiresAt
    }
}
