import SwiftUI

struct AddTaskSheetView: View {

    @State private var taskText = ""
    @State private var showingTimePicker = false
    @State private var expiryTime = Date()
    @State private var selectedDetent: PresentationDetent = .height(200)
    @Environment(\.dismiss) private var dismiss

    private var pickerRange: ClosedRange<Date> {
        let startOfTomorrow = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        return Date()...startOfTomorrow
    }

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
        .presentationDetents([.height(200), .height(420)], selection: $selectedDetent)
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

    // MARK: - Expiry row + picker

    private var expiryRow: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.paper(duration: MotionDuration.medium)) {
                    showingTimePicker.toggle()
                    selectedDetent = showingTimePicker ? .height(420) : .height(200)
                }
            } label: {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: showingTimePicker ? "clock.fill" : "clock")
                        .font(.system(size: AppConstants.sheetClockIconSize))
                        .foregroundStyle(showingTimePicker ? Color.accent : Color.sheetMuted)
                    Text(showingTimePicker
                         ? expiryTime.formatted(date: .omitted, time: .shortened)
                         : "Set an expiry time (optional)")
                        .todayStyle(.sheetExpiry)
                        .foregroundStyle(showingTimePicker ? Color.accent : Color.sheetMuted)
                    Spacer()
                    if showingTimePicker {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: AppConstants.sheetClockIconSize))
                            .foregroundStyle(Color.inkQuaternary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
            }
            .buttonStyle(.plain)

            if showingTimePicker {
                DatePicker(
                    "",
                    selection: $expiryTime,
                    in: pickerRange,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#F2EEE6"))
                .clipShape(RoundedRectangle(cornerRadius: Radii.md))
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.md)
            }
        }
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
    Color.bgBase.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            AddTaskSheetView()
        }
}
