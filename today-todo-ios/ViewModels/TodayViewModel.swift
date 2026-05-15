import SwiftUI
import Observation

// MARK: - Time-of-day state

enum TimeOfDay {
    case morning    // 6 am – 12 pm
    case midday     // 12 pm – 5 pm
    case evening    // 5 pm – 11 pm (sunset trigger at 11 pm)
    case night      // 11 pm – 6 am
}

// MARK: - ViewModel

@Observable
final class TodayViewModel {

    // MARK: State
    var todayTasks: [TodoItem] = []
    var isAddingTask = false

    // MARK: Derived — time of day
    // NOTE: Real implementation will use DateService. Direct Date() call here
    // is intentional for the stub; replace when DateService is injected.
    var timeOfDay: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<23:  return .morning
        //case 12..<17: return .midday
        //case 17..<23: return .evening
        default:      return .night
        }
    }

    // MARK: Derived — background gradient
    var timeOfDayGradient: LinearGradient {
        switch timeOfDay {
        case .morning:        return .todayMorning
        case .midday:         return .todayMidday
        case .evening, .night: return .todaySunset
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
            case .midday:  return "Four things."
            case .evening: return "The day softens."
            case .night:   return "Almost there."
            }
        }
        return countTitle(for: incomplete.count)
    }

    /// Shown only in empty + sunset states below the title.
    var headerSubtitle: String? {
        guard todayTasks.filter({ !$0.isCompleted }).isEmpty else { return nil }
        switch timeOfDay {
        case .morning: return "Begin gently."
        case .midday:  return "Begin gently."
        case .evening: return "An hour remains until midnight."
        case .night:   return "Whatever's left, tomorrow is a clean start."
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
