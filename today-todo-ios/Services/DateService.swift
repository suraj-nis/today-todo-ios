import Foundation

/// All date logic lives here. No View or ViewModel calls Date() directly.
struct DateService {
    var today: Date          { Date() }
    var todayKey: String     { dayKey(for: Date()) }
    var startOfToday: Date   { Calendar.current.startOfDay(for: Date()) }
    var endOfToday: Date     { Calendar.current.date(byAdding: .day, value: 1, to: startOfToday) ?? Date() }

    func dayKey(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    func isToday(_ item: TodoItem) -> Bool { item.dayKey == todayKey }
    func isExpired(_ item: TodoItem) -> Bool {
        guard let exp = item.expiresAt else { return false }
        return exp < Date()
    }
    func minutesUntilEndOfDay() -> Int {
        max(0, Int(endOfToday.timeIntervalSince(Date()) / 60))
    }
}
