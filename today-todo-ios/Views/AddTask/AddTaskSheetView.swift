import SwiftUI

struct AddTaskSheetView: View {

    @State private var taskText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            grabber
            navRow
            textField
            divider()
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
            expiryRow
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .presentationDetents([.height(200)])
        .presentationCornerRadius(AppConstants.sheetCornerRadius)
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color(hex: "#F2EEE6"))
    }

    // MARK: - Grabber

    private var grabber: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: AppConstants.sheetGrabberRadius)
                .fill(Color(hex: "#d0c8b6"))
                .frame(width: AppConstants.sheetGrabberWidth,
                       height: AppConstants.sheetGrabberHeight)
            Spacer()
        }
        .padding(.top, Spacing.md)
        .padding(.leading, Spacing.xs+2) // Change this later to be adapting
    }

    // MARK: - Nav row

    private var navRow: some View {
        HStack {
            Button("Cancel") {
                taskText = ""
                dismiss()
            }
            .todayStyle(.sheetAction)
            .foregroundStyle(Color.inkSecondary)

            Spacer()

            HStack(spacing: Spacing.sm) {
                Text("NEW")
                Text("·")
                Text("TODAY")
            }
            .todayStyle(.caption)
            .tracking(1.4)
            .foregroundStyle(Color.sheetMuted)

            Spacer()

            Button("Add") { }
                .todayStyle(.sheetAction)
                .foregroundStyle(taskText.isEmpty ? Color.inkQuaternary : Color.accent)
                .disabled(taskText.isEmpty)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Text field

    private var textField: some View {
        ZStack(alignment: .topLeading) {
            if taskText.isEmpty {
                Text("What's on your mind?")
                    .todayStyle(.subtitle)
                    .foregroundStyle(Color.sheetMuted)
                    .allowsHitTesting(false)
            }
            TextField("", text: $taskText)
                .font(.todaySubtitle)
                .foregroundStyle(Color.inkPrimary)
                .tint(Color.inkPrimary)
        }
        .frame(minHeight: AppConstants.sheetMinTextHeight, alignment: .topLeading)
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
    }

    // MARK: - Expiry row

    private var expiryRow: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "clock")
                .font(.system(size: AppConstants.sheetClockIconSize))
                .foregroundStyle(Color.sheetMuted)
            Text("Set an expiry time (optional)")
                .todayStyle(.sheetExpiry)
                .foregroundStyle(Color.sheetMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Helpers

    private func divider() -> some View {
        Rectangle()
            .fill(Color.dividerStrong)
            .frame(height: 1)
    }
}

// MARK: - Preview

#Preview {
    Color.bgBase
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            AddTaskSheetView()
        }
}
