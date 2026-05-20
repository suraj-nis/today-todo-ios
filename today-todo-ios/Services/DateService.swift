import Foundation

// MARK: - Protocol

protocol DateServiceProtocol {
    var now: Date { get }
    var todayKey: String { get }
    var startOfToday: Date { get }
    var endOfToday: Date { get }
    func dayKey(for date: Date) -> String
    func dateFromKey(_ key: String) -> Date?
    func dayName(for date: Date) -> String
    func dateLabel(for date: Date) -> String
    func isYesterday(_ date: Date) -> Bool
    func isToday(_ item: TodoItem) -> Bool
    func isExpired(_ item: TodoItem) -> Bool
    func timeUntilMidnight() -> String
}

// MARK: - Default implementations

extension DateServiceProtocol {

    var todayKey: String { dayKey(for: now) }

    var startOfToday: Date {
        Calendar.current.startOfDay(for: now)
    }

    var endOfToday: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfToday) ?? now
    }

    func dayKey(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    func dateFromKey(_ key: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: key)
    }

    func isYesterday(_ date: Date) -> Bool {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)
        else { return false }
        return Calendar.current.isDate(date, inSameDayAs: yesterday)
    }

    /// "Yesterday" if the date is yesterday; full weekday name ("Monday") otherwise.
    func dayName(for date: Date) -> String {
        if isYesterday(date) { return "Yesterday" }
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: date)
    }

    /// "MAY 13" — month abbreviation + day, uppercased.
    func dateLabel(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date).uppercased()
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
            let hours = (minutes + 30) / 60
            return hours == 1 ? "1 hour" : "\(hours) hours"
        }
    }
}

// MARK: - Live implementation

struct LiveDateService: DateServiceProtocol {
    var now: Date { Date() }
}

// MARK: - Mock (for testing / previews)

struct MockDateService: DateServiceProtocol {
    var now: Date
}
