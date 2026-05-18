import SwiftUI

@main
struct today_todo_iosApp: App {

    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = TodayViewModel()

    var body: some Scene {
        WindowGroup {
            TodayTabBarView(viewModel: viewModel)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                viewModel.refresh()
            }
        }
    }
}
