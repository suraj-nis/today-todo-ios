import Foundation

// MARK: - Protocol

protocol DateServiceProtocol {
    var now: Date { get }
    var todayKey: String { get }
    var startOfToday: Date { get }
    var endOfToday: Date { get }
    func isToday(_ item: TodoItem) -> Bool
    func isExpired(_ item: TodoItem) -> Bool
    func timeUntilMidnight() -> String
}

// MARK: - Default implementations

extension DateServiceProtocol {

    var todayKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: now)
    }

    var startOfToday: Date {
        Calendar.current.startOfDay(for: now)
    }

    var endOfToday: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfToday) ?? now
    }

    func isToday(_ item: TodoItem) -> Bool {
        item.dayKey == todayKey
    }

    func isExpired(_ item: TodoItem) -> Bool {
        guard let exp = item.expiresAt else { return false }
        return exp < now
    }

    func timeUntilMidnight() -> String {
        let minutes = max(0, Int(endOfToday.timeIntervalSince(now) / 60))
        switch minutes {
        case ..<2:   return "moments"
        case ..<60:  return "\(minutes) minutes"
        default:
            // Round up if 30+ minutes past the hour, otherwise round down
            let hours = (minutes + 30) / 60
            return hours == 1 ? "1 hour" : "\(hours) hours"
        }
    }
}

// MARK: - Live implementation

struct LiveDateService: DateServiceProtocol {
    var now: Date { Date() }
}

// MARK: - Mock (for testing)

struct MockDateService: DateServiceProtocol {
    var now: Date

    init(now: Date) {
        self.now = now
    }
}
