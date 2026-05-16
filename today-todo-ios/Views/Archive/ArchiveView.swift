import SwiftUI

struct ArchiveView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgBase.ignoresSafeArea()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    ArchiveView()
}
