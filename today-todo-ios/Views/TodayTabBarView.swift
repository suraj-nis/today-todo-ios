import SwiftUI

struct TodayTabBarView: View {

    let viewModel: TodayViewModel

    var body: some View {
        TabView {
            TodayView(viewModel: viewModel)
                .tabItem {
                    Label("TODAY", systemImage: "calendar")
                }
            ArchiveView(timeOfDay: viewModel.timeOfDay)
                .tabItem {
                    Label("ARCHIVE", systemImage: "archivebox")
                }
        }
        .tint(Color.accent)
        .toolbarBackground(.hidden, for: .tabBar)
        .onAppear {
               UITabBar.appearance().backgroundImage = UIImage()
               UITabBar.appearance().shadowImage = UIImage()
               UITabBar.appearance().backgroundColor = .clear
               UITabBar.appearance().isTranslucent = true
               UITabBar.appearance().itemPositioning = .centered
               UITabBar.appearance().itemSpacing = 70 //Magic number for now
        }
    }
}

#Preview {
    TodayTabBarView(viewModel: TodayViewModel())
}
