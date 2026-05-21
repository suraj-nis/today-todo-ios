import Foundation

protocol ArchiveRepositoryProtocol {
    /// Returns all archived days. Order is not guaranteed — sort at the call site.
    func loadAll() -> [ArchivedDay]
    /// Persists the full archive, replacing whatever was stored.
    func save(_ days: [ArchivedDay])
    /// Constructs and appends one ArchivedDay for the given tasks and date.
    /// No-ops if a day with the same dayKey is already archived (idempotent).
    func archiveTasks(_ tasks: [TodoItem], for date: Date)
    /// Removes the archived day with the given id. No-ops if not found.
    func deleteDay(withId id: UUID)
}
