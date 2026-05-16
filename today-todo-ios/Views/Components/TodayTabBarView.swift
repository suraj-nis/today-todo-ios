import SwiftUI

struct TodayTabBar: View {

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("TODAY", systemImage: "calendar")
                }
            ArchiveView()
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
    TodayTabBar()
}
