import SwiftUI

// MARK: - Helpers

private func fixedDate(hour: Int) -> Date {
    Calendar.current.date(
        bySettingHour: hour, minute: 0, second: 0, of: Date()
    ) ?? Date()
}

private func makeVM(hour: Int, tasks: [TodoItem] = []) -> TodayViewModel {
    let vm = TodayViewModel(dateService: MockDateService(now: fixedDate(hour: hour)))
    vm.todayTasks = tasks
    return vm
}

private let sampleTasks: [TodoItem] = {
    let key = LiveDateService().todayKey
    return [
        TodoItem(id: UUID(), title: "Walk after lunch",
                 isCompleted: false, createdAt: Date(), dayKey: key),
        TodoItem(id: UUID(), title: "Read the Berry essay on attention",
                 isCompleted: true,  createdAt: Date(), dayKey: key),
        TodoItem(id: UUID(), title: "Call the landlord",
                 isCompleted: false, createdAt: Date(), dayKey: key),
    ]
}()

// MARK: - Preview shell (mirrors TodayTabBar layout)

private struct PreviewShell: View {
    let viewModel: TodayViewModel

    var body: some View {
        TabView {
            TodayView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("TODAY")
                }
            ArchiveView()
                .tabItem {
                    Image(systemName: "archivebox")
                    Text("ARCHIVE")
                }
        }
        .tint(Color.accent)
        .toolbarBackground(.hidden, for: .tabBar)
        .onAppear {
            UITabBar.appearance().backgroundImage = UIImage()
            UITabBar.appearance().shadowImage    = UIImage()
            UITabBar.appearance().backgroundColor = .clear
            UITabBar.appearance().isTranslucent   = true
            UITabBar.appearance().itemPositioning = .centered
            UITabBar.appearance().itemSpacing     = 70
        }
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
