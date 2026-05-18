import SwiftUI
import Observation

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

    @ObservationIgnored private let repository: TodoRepositoryProtocol
    @ObservationIgnored private let dateService: DateServiceProtocol
    @ObservationIgnored private let haptics = HapticService()

    init(
        repository: TodoRepositoryProtocol = UserDefaultsTodoRepository(),
        dateService: DateServiceProtocol = LiveDateService()
    ) {
        self.repository  = repository
        self.dateService = dateService
        load()
    }

    // MARK: - Derived — today filtered (unsorted)

    private var todayItems: [TodoItem] {
        items.filter { dateService.isToday($0) }
    }

    // MARK: - Derived — sorted display array

    var sortedTodayTasks: [TodoItem] {
        // Group 1: incomplete with expiry, not yet expired — most urgent first
        let expiringTasks = todayItems
            .filter { !$0.isCompleted && $0.expiresAt != nil && !dateService.isExpired($0) }
            .sorted { $0.expiresAt! < $1.expiresAt! }

        // Group 2: incomplete with no expiry — creation order
        let nonExpiringTasks = todayItems
            .filter { !$0.isCompleted && $0.expiresAt == nil }
            .sorted { $0.createdAt < $1.createdAt }

        // Group 3: completed — most recently completed first
        let completedTasks = todayItems
            .filter { $0.isCompleted }
            .sorted {
                ($0.completedAt ?? $0.createdAt) > ($1.completedAt ?? $1.createdAt)
            }

        // Group 4: expired (incomplete, past expiry time) — at the very bottom
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

        let item = TodoItem(title: trimmed, expiresAt: expiresAt, dateService: dateService)
        items.append(item)
        persist()
        haptics.impact(.soft)
    }

    func deleteTask(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
        persist()
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
    }

    // MARK: - Lifecycle

    /// Re-loads from storage. Call on app foreground to handle midnight resets.
    func refresh() {
        load()
    }

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
