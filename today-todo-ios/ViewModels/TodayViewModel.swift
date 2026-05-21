import SwiftUI
import Observation
import WidgetKit

// MARK: - Time-of-day state

enum TimeOfDay {
    case morning    // 6 am – 12 pm
    case midday     // 12 pm – 5 pm
    case evening    // 5 pm – 6 am
}

// MARK: - ViewModel

@Observable
final class TodayViewModel {

    // MARK: Private source of truth (insertion order)

    private var items: [TodoItem] = []

    @ObservationIgnored private let repository:        TodoRepositoryProtocol
    @ObservationIgnored private let dateService:       DateServiceProtocol
    @ObservationIgnored private let archiveRepository: ArchiveRepositoryProtocol
    @ObservationIgnored private let haptics = HapticService()

    init(
        dateService:       DateServiceProtocol       = LiveDateService(),
        repository:        TodoRepositoryProtocol    = UserDefaultsTodoRepository(),
        archiveRepository: ArchiveRepositoryProtocol = UserDefaultsArchiveRepository()
    ) {
        self.dateService       = dateService
        self.repository        = repository
        self.archiveRepository = archiveRepository
        load()
        performDayReset()
        scheduleMidnightReset()
        items.forEach { scheduleExpiryUIUpdate(for: $0) }
    }

    // MARK: - Derived — today filtered (unsorted)

    private var todayItems: [TodoItem] {
        items.filter { dateService.isToday($0) }
    }

    // MARK: - Derived — sorted display array

    var sortedTodayTasks: [TodoItem] {
        let expiringTasks = todayItems
            .filter { !$0.isCompleted && $0.expiresAt != nil && !dateService.isExpired($0) }
            .sorted { $0.expiresAt! < $1.expiresAt! }

        let nonExpiringTasks = todayItems
            .filter { !$0.isCompleted && $0.expiresAt == nil }
            .sorted { $0.createdAt < $1.createdAt }

        let completedTasks = todayItems
            .filter { $0.isCompleted }
            .sorted { ($0.completedAt ?? $0.createdAt) > ($1.completedAt ?? $1.createdAt) }

        let expiredTasks = todayItems
            .filter { !$0.isCompleted && dateService.isExpired($0) }
            .sorted { $0.expiresAt! < $1.expiresAt! }

        return expiringTasks + nonExpiringTasks + completedTasks + expiredTasks
    }

    func isTaskExpired(_ task: TodoItem) -> Bool {
        dateService.isExpired(task)
    }

    var isAtCapacity: Bool { todayItems.count >= 10 }

    // MARK: - Derived — time of day

    var timeOfDay: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: dateService.now)
        switch hour {
        case 6..<12:  return .morning
        case 12..<17: return .midday
        default:      return .evening
        }
    }

    var timeOfDayGradient: LinearGradient {
        switch timeOfDay {
        case .morning: return .todayMorning
        case .midday:  return .todayMidday
        case .evening: return .todaySunset
        }
    }

    // MARK: - Derived — header copy

    var dateKickerText: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE  ·  MMM d"
        return f.string(from: dateService.now).uppercased()
    }

    var headerTitle: String {
        let incomplete = sortedTodayTasks.filter { !$0.isCompleted && !dateService.isExpired($0) }
        if incomplete.isEmpty {
            switch timeOfDay {
            case .morning: return "A clean slate."
            case .midday:  return "The day is yours."
            case .evening: return "The day softens."
            }
        }
        return countTitle(for: incomplete.count)
    }

    var headerSubtitle: String? {
        switch timeOfDay {
        case .morning: return "Begin gently."
        case .midday:  return "Keep going."
        case .evening: return "\(dateService.timeUntilMidnight()) remain until midnight."
        }
    }

    // MARK: - Actions

    func addTask(title: String, expiresAt: Date? = nil) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isAtCapacity else { return }

        let item = TodoItem(
            title:     trimmed,
            createdAt: dateService.now,
            dayKey:    dateService.todayKey,
            expiresAt: expiresAt
        )
        items.append(item)
        scheduleExpiryUIUpdate(for: item)
        persist()
        WidgetCenter.shared.reloadAllTimelines()
        haptics.impact(.soft)
    }

    func deleteTask(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
        persist()
        WidgetCenter.shared.reloadAllTimelines()
        haptics.impact(.medium)
    }

    func toggleComplete(_ task: TodoItem) {
        guard let i = items.firstIndex(where: { $0.id == task.id }) else { return }
        items[i].isCompleted.toggle()
        if items[i].isCompleted {
            items[i].completedAt = dateService.now
            haptics.notification(.success)
        } else {
            items[i].completedAt = nil
            haptics.impact(.light)
        }
        persist()
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Lifecycle

    /// Reloads from storage and runs a day reset check.
    /// Call on app foreground to handle waking after midnight.
    func refresh() {
        load()
        performDayReset()
        items.forEach { scheduleExpiryUIUpdate(for: $0) }
    }

    // MARK: - Day reset

    /// Moves all non-today tasks into the archive, then removes them from the
    /// active list. Idempotent — safe to call multiple times.
    private func performDayReset() {
        let todayKey      = dateService.todayKey
        let previousTasks = items.filter { $0.dayKey != todayKey }
        print("DEBUG: previousTasks count: \(previousTasks.count)")
        guard !previousTasks.isEmpty else { return }

        let grouped = Dictionary(grouping: previousTasks, by: { $0.dayKey })
        print("DEBUG: grouped keys: \(grouped.keys)")
        for (dayKey, tasks) in grouped {
            guard let date = dateService.dateFromKey(dayKey) else { continue }
            archiveRepository.archiveTasks(tasks, for: date)
        }

        items.removeAll { $0.dayKey != todayKey }
        persist()
        WidgetCenter.shared.reloadAllTimelines()
        NotificationCenter.default.post(name: .archiveDidUpdate, object: nil)
    }

    /// Fires exactly at a task's expiry time and reassigns `items` so
    /// @Observable notifies SwiftUI to redraw the expired row immediately.
    private func scheduleExpiryUIUpdate(for task: TodoItem) {
        guard let expiresAt = task.expiresAt,
              expiresAt > dateService.now,
              !task.isCompleted else { return }

        let delay = expiresAt.timeIntervalSince(dateService.now)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            self.items = self.items
        }
    }

    /// Schedules a single fire exactly at the next midnight, then reschedules
    /// itself so the ViewModel self-maintains across days without requiring
    /// the user to background/foreground the app.
    private func scheduleMidnightReset() {
        let now      = dateService.now
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        let midnight = calendar.startOfDay(for: tomorrow)
        let delay    = midnight.timeIntervalSince(now)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.performDayReset()
            self?.scheduleMidnightReset()
        }
    }

    // MARK: - Debug helpers

#if DEBUG
    func simulateDayReset(daysAgo: Int = 1) {
        let calendar = Calendar.current
        guard let pastDate = calendar.date(byAdding: .day, value: -daysAgo, to: dateService.now)
        else { return }

        let pastDayKey = dateService.dayKey(for: pastDate)

        var existing = archiveRepository.loadAll()
        existing.removeAll { dateService.dayKey(for: $0.date) == pastDayKey }
        archiveRepository.save(existing)

        items = items.map { task in
            TodoItem(
                id:          task.id,
                title:       task.title,
                isCompleted: task.isCompleted,
                completedAt: task.completedAt,
                createdAt:   pastDate,
                dayKey:      pastDayKey,
                expiresAt:   task.expiresAt
            )
        }

        repository.save(items)
        print("DEBUG: items before reset: \(items.count)")
        print("DEBUG: pastDayKey: \(pastDayKey)")
        performDayReset()
    }
#endif

    // MARK: - Private helpers

    private func load() {
        items = repository.loadAll()
    }

    private func persist() {
        repository.save(items)
    }

    private func countTitle(for n: Int) -> String {
        let words = ["One", "Two", "Three", "Four", "Five",
                     "Six", "Seven", "Eight", "Nine", "Ten"]
        let word = n <= words.count ? words[n - 1] : "\(n)"
        return n == 1 ? "\(word) thing." : "\(word) things."
    }
}
