import SwiftUI

// MARK: - Preview-only convenience init
//
// Restores the old TodoItem(title:expiresAt:dateService:) signature so all
// preview call sites below stay unchanged. Not compiled into the widget target.

private extension TodoItem {
    init(title: String, expiresAt: Date? = nil,
         dateService: DateServiceProtocol = LiveDateService()) {
        self.init(
            title:     title,
            createdAt: dateService.now,
            dayKey:    dateService.todayKey,
            expiresAt: expiresAt
        )
    }
}

// MARK: - Helpers

private func fixedDate(hour: Int) -> Date {
    Calendar.current.date(
        bySettingHour: hour, minute: 0, second: 0, of: Date()
    ) ?? Date()
}

/// In-memory repository used only in Xcode previews.
private final class PreviewRepository: TodoRepositoryProtocol {
    private var items: [TodoItem]
    init(_ items: [TodoItem] = []) { self.items = items }
    func loadAll() -> [TodoItem] { items }
    func save(_ items: [TodoItem]) { self.items = items }
}

private func makeVM(hour: Int, tasks: [TodoItem] = []) -> TodayViewModel {
    let dateService = MockDateService(now: fixedDate(hour: hour))
    let repo = PreviewRepository(tasks)
    return TodayViewModel( dateService: dateService,repository: repo)
}

private func expiredTask(title: String, minutesAgo: Int, dateService: DateServiceProtocol) -> TodoItem {
    let expiry = dateService.now.addingTimeInterval(-Double(minutesAgo) * 60)
    return TodoItem(title: title, expiresAt: expiry, dateService: dateService)
}

private let sampleTasks: [TodoItem] = [
    TodoItem(title: "Walk after lunch"),
    TodoItem(title: "Read the Berry essay on attention"),
    TodoItem(title: "Call the landlord"),
]

private func expiredTasks(hour: Int) -> [TodoItem] {
    let ds = MockDateService(now: fixedDate(hour: hour))
    return [
        expiredTask(title: "Reply to Marcus", minutesAgo: 90, dateService: ds),
        expiredTask(title: "Submit the form before noon", minutesAgo: 30, dateService: ds),
        TodoItem(title: "Water the plants"),
    ]
}

// MARK: - Preview shell (mirrors TodayTabBar layout)

private struct PreviewShell: View {
    let viewModel: TodayViewModel

    var body: some View {
        TodayTabBarView(viewModel: viewModel)
    }
}

// MARK: - Morning

#Preview("Morning — Empty") {
    PreviewShell(viewModel: makeVM(hour: 8))
}

#Preview("Morning — With Tasks") {
    PreviewShell(viewModel: makeVM(hour: 8, tasks: sampleTasks))
}

// MARK: - Midday

#Preview("Midday — Empty") {
    PreviewShell(viewModel: makeVM(hour: 13))
}

#Preview("Midday — With Tasks") {
    PreviewShell(viewModel: makeVM(hour: 13, tasks: sampleTasks))
}

// MARK: - Evening

#Preview("Evening — Empty") {
    PreviewShell(viewModel: makeVM(hour: 19))
}

#Preview("Evening — With Tasks") {
    PreviewShell(viewModel: makeVM(hour: 19, tasks: sampleTasks))
}

// MARK: - Expired tasks

#Preview("Morning — Expired Tasks") {
    PreviewShell(viewModel: makeVM(hour: 10, tasks: expiredTasks(hour: 10)))
}

#Preview("Evening — Expired Tasks") {
    PreviewShell(viewModel: makeVM(hour: 19, tasks: expiredTasks(hour: 19)))
}
