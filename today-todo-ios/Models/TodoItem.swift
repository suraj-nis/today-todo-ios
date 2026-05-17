import Foundation

struct TodoItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    let createdAt: Date
    let dayKey: String      // "yyyy-MM-dd" — buckets tasks by calendar day
    var expiresAt: Date?    // optional same-day expiry; always < end of createdAt day
    
}
