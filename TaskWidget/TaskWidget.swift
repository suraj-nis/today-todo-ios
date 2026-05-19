import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct TaskEntry: TimelineEntry {
    let date: Date
    let tasks: [TodoItem]
    let todayKey: String

    // MARK: Derived

    var todayTasks: [TodoItem] {
        tasks.filter { $0.dayKey == todayKey }
    }

    var incompleteTasks: [TodoItem] {
        todayTasks.filter { !$0.isCompleted && !isExpired($0) }
    }

    var completedTasks: [TodoItem] {
        todayTasks.filter { $0.isCompleted }
    }

    var incompleteCount: Int { incompleteTasks.count }
    var completedCount:  Int { completedTasks.count }
    var totalCount:      Int { todayTasks.count }

    /// "THU · MAY 14" — short weekday, month abbreviation, day number.
    var dateKicker: String {
        let f = DateFormatter()
        f.dateFormat = "EEE · MMM d"
        return f.string(from: date).uppercased()
    }

    private func isExpired(_ item: TodoItem) -> Bool {
        guard let exp = item.expiresAt else { return false }
        return exp < date
    }
}

// MARK: - Timeline Provider

struct TaskWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), tasks: [], todayKey: dayKey(for: Date()))
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        let entry = currentEntry()
        // Only refresh at midnight — WidgetCenter.reloadAllTimelines() from the
        // main app handles all intra-day updates (add / complete / delete).
        let tomorrow       = Calendar.current.date(byAdding: .day, value: 1, to: entry.date) ?? entry.date
        let nextMidnight   = Calendar.current.startOfDay(for: tomorrow)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }

    // MARK: - Private

    private func currentEntry() -> TaskEntry {
        let tasks = SharedTodoStore.loadAll()
        let now   = Date()
        return TaskEntry(date: now, tasks: tasks, todayKey: dayKey(for: now))
    }

    private func dayKey(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

// MARK: - Entry View (routes to size-specific views)

struct TaskWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: TaskEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration

struct TaskWidget: Widget {
    let kind = "TaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskWidgetProvider()) { entry in
            TaskWidgetEntryView(entry: entry)
                .containerBackground(
                    Color(red: 0xF2/255, green: 0xEE/255, blue: 0xE6/255),
                    for: .widget
                )
        }
        .configurationDisplayName("Today.")
        .description("Your tasks for today.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
