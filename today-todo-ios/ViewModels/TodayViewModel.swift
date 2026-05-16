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
    var todayTasks: [TodoItem] = []
    var isAddingTask = false

    private let dateService = DateService()

    // MARK: Derived — time of day
    // NOTE: Real implementation will use DateService. Direct Date() call here
    // is intentional for the stub; replace when DateService is injected.
    var timeOfDay: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
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
        return f.string(from: Date()).uppercased()
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

    /// Shown only in empty + sunset states below the title.
    var headerSubtitle: String? {
        guard todayTasks.filter({ !$0.isCompleted }).isEmpty else { return nil }
        switch timeOfDay {
        case .morning: return "Begin gently."
        case .midday:  return "Keep going"
        case .evening: return "\(dateService.timeRemainingUntilMidnight()) remain until midnight."
        }
    }

    // MARK: Actions (stubs — real logic added with Repository layer)

    func toggleComplete(_ task: TodoItem) {
        guard let i = todayTasks.firstIndex(where: { $0.id == task.id }) else { return }
        todayTasks[i].isCompleted.toggle()
    }

    // MARK: - Private helpers

    private func countTitle(for n: Int) -> String {
        let words = ["One","Two","Three","Four","Five",
                     "Six","Seven","Eight","Nine","Ten"]
        let word = n <= words.count ? words[n - 1] : "\(n)"
        return n == 1 ? "\(word) thing." : "\(word) things."
    }
}
