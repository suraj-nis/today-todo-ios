import Foundation
import WidgetKit

struct UserDefaultsArchiveRepository: ArchiveRepositoryProtocol {

    private let dateService: DateServiceProtocol
    private let suiteName = "group.codemiracles.today-todo-ios"
    private let key = "com.today.archive"

    init(dateService: DateServiceProtocol = LiveDateService()) {
        self.dateService = dateService
    }

    // MARK: - ArchiveRepositoryProtocol

    func loadAll() -> [ArchivedDay] {
        guard
            let defaults = UserDefaults(suiteName: suiteName),
            let data     = defaults.data(forKey: key)
        else { return [] }
        let decoded = (try? JSONDecoder().decode([ArchivedDay].self, from: data)) ?? []
        print("DEBUG: loaded archive days: \(decoded.count)")
        return decoded
    }

    func save(_ days: [ArchivedDay]) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        guard let data = try? JSONEncoder().encode(days) else { return }
        defaults.set(data, forKey: key)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func deleteDay(withId id: UUID) {
        var existing = loadAll()
        existing.removeAll { $0.id == id }
        save(existing)
    }

    /// Builds one ArchivedDay from raw tasks and appends it to the archive.
    /// Skips silently if a day with the same dayKey is already stored.
    func archiveTasks(_ tasks: [TodoItem], for date: Date) {
        var existing = loadAll()

        let targetKey = dateService.dayKey(for: date)
        guard !existing.contains(where: { dateService.dayKey(for: $0.date) == targetKey })
        else { return }

        let archivedDay = ArchivedDay(
            id:        UUID(),
            dayName:   dateService.dayName(for: date),
            date:      date,
            dateLabel: dateService.dateLabel(for: date),
            tasks:     tasks
        )
        print("DEBUG: archiving day: \(archivedDay.dayName) tasks: \(tasks.count)")

        existing.append(archivedDay)
        save(existing)
    }
}
