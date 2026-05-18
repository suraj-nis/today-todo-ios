import SwiftUI

struct AddTaskSheetView: View {

    let viewModel: TodayViewModel

    @State private var taskText = ""
    @State private var showingTimePicker = false
    @State private var expiryTime = Date()
    @State private var minimumTime = Date()
    @State private var selectedDetent: PresentationDetent = .height(200)
    @State private var currentTimeText = ""
    @Environment(\.dismiss) private var dismiss

    private var pickerRange: ClosedRange<Date> {
        let endOfToday = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        let lower = min(minimumTime, endOfToday)
        return lower...endOfToday
    }

    private func nextWholeMinute() -> Date {
        let plus60 = Date().addingTimeInterval(60)
        let cal = Calendar.current
        let seconds = cal.component(.second, from: plus60)
        guard seconds > 0 else { return plus60 }
        return cal.date(byAdding: .second, value: 60 - seconds, to: plus60) ?? plus60
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

            Button("Add") {
                if viewModel.isAtCapacity {
                    taskText = "That's enough for today."
                    return
                }
                viewModel.addTask(
                    title: taskText,
                    expiresAt: showingTimePicker ? expiryTime : nil
                )
                taskText = ""
                dismiss()
            }
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
                    if showingTimePicker {
                        Image(systemName: "clock.fill")
                            .font(.system(size: AppConstants.sheetClockIconSize))
                            .foregroundStyle(Color.accent)
                        Text(currentTimeText)
                            .todayStyle(.sheetExpiry)
                            .foregroundStyle(Color.accent)
                    } else {
                        Text("Set an expiry time (optional)")
                            .todayStyle(.sheetExpiry)
                            .foregroundStyle(Color.sheetMuted)
                    }
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
            .onAppear {
                let f = DateFormatter()
                f.dateFormat = "h:mm a"
                currentTimeText = f.string(from: Date())
            }

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
                .onAppear {
                    minimumTime = nextWholeMinute()
                    if expiryTime < minimumTime {
                        expiryTime = minimumTime
                    }
                }
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
            AddTaskSheetView(viewModel: TodayViewModel())
        }
}
