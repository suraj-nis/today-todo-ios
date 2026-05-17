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

    // MARK: State
    var todayTasks: [TodoItem] = [TodoItem(id: UUID(), title: "Walk after lunch", isCompleted: false, createdAt: Date(), dayKey: "17", expiresAt: Date()),
                                  TodoItem(id: UUID(), title: "Water the lemon tree", isCompleted: false, createdAt: Date(), dayKey: "17", expiresAt: Date()),
                                  TodoItem(id: UUID(), title: "Read the Berry essay on attention", isCompleted: false, createdAt: Date(), dayKey: "17"),
                                  TodoItem(id: UUID(), title: "Reply to Anna's letter", isCompleted: true, createdAt: Date(), dayKey: "17"),
                                  TodoItem(id: UUID(), title: "Call mom", isCompleted: true, createdAt: Date(), dayKey: "17")]
    var isAddingTask = false

    @ObservationIgnored
    private let dateService: DateServiceProtocol

    init(dateService: DateServiceProtocol = LiveDateService()) {
        self.dateService = dateService
    }

    // MARK: Derived — time of day

    var timeOfDay: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: dateService.now)
        switch hour {
        case 6..<12:  return .morning
        case 12..<17: return .midday
        default:      return .evening
        }
    }

    // MARK: Derived — background gradient

    var timeOfDayGradient: LinearGradient {
        switch timeOfDay {
        case .morning: return .todayMorning
        case .midday:  return .todayMidday
        case .evening: return .todaySunset
        }
    }

    // MARK: Derived — header copy

    var dateKickerText: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE  ·  MMM d"
        return f.string(from: dateService.now).uppercased()
    }

    /// Dynamic title: reflects task count when tasks exist; time-of-day copy when empty.
    var headerTitle: String {
        let incomplete = todayTasks.filter { !$0.isCompleted }
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

    // MARK: Actions

    func toggleComplete(_ task: TodoItem) {
        guard let i = todayTasks.firstIndex(where: { $0.id == task.id }) else { return }
        todayTasks[i].isCompleted.toggle()
    }

    // MARK: - Private helpers

    private func countTitle(for n: Int) -> String {
        let words = ["One", "Two", "Three", "Four", "Five",
                     "Six", "Seven", "Eight", "Nine", "Ten"]
        let word = n <= words.count ? words[n - 1] : "\(n)"
        return n == 1 ? "\(word) thing." : "\(word) things."
    }
}
