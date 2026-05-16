import SwiftUI

struct TodayView: View {

    @State private var viewModel = TodayViewModel()
    @State private var isAddingTask = false

    @ScaledMetric(relativeTo: .body) private var fabSize        = AppConstants.fabSize
    @ScaledMetric(relativeTo: .body) private var fabBottomPad   = AppConstants.fabBottomPadding

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                
                    backgroundLayer
                    scrollLayer
                    fabButton
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            
        }
        .sheet(isPresented: $isAddingTask) {
            // AddTaskSheet replaces this in Step 5
            Text("Add task — coming soon")
                .presentationDetents([.medium])
                .presentationCornerRadius(AppConstants.sheetCornerRadius)
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        viewModel.timeOfDayGradient
            .ignoresSafeArea()
    }

    // MARK: - Scrollable content

    private var scrollLayer: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.xxl)

                    if viewModel.todayTasks.isEmpty {
                        emptyContent
                            .frame(
                                maxWidth: .infinity,
                                minHeight: geo.size.height 
                            )
                    } else {
                        taskList
                    }

                    Spacer(minLength: fabSize + fabBottomPad + CGFloat(AppConstants.tabBarHeight))
                }
                .frame(minHeight: geo.size.height, alignment: .top)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.dateKickerText)
                .todayStyle(.dateKicker)
                .foregroundStyle(Color.inkPrimary)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.headerTitle)
                .todayStyle(.heroTitle)
                .foregroundStyle(Color.inkPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Spacing.sm)

            if let subtitle = viewModel.headerSubtitle {
                Text(subtitle)
                    .todayStyle(.subtitle)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 6)
                    .opacity(0.8)
                    
            }
        }
    }

    // MARK: - Empty content

    private var emptyContent: some View {
        EmptyStateView()
    }

    // MARK: - Task list

    private var taskList: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(viewModel.todayTasks.enumerated()), id: \.element.id) { index, task in
                TaskRowView(task: task) {
                    withAnimation(.circleComplete) {
                        viewModel.toggleComplete(task)
                    }
                }

                if index < viewModel.todayTasks.count - 1 {
                    Divider()
                        .background(Color.divider)
                        // Indent divider to align with task text, past circle + gap
                        .padding(.leading, Spacing.xxl + AppConstants.checkCircleSize + Spacing.md)
                }
            }
        }
        .background(Color.bgCanvas)
        .clipShape(RoundedRectangle(cornerRadius: Radii.lg))
        .shadowStyle(.raised)
        .padding(.horizontal, Spacing.xxl)
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button {
            isAddingTask = true
        } label: {
            Image(systemName: "plus")
                .imageScale(.large)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: fabSize, height: fabSize)
                .background(Color.accent)
                .clipShape(Circle())
                .shadowStyle(.floating)
        }
        .accessibilityLabel("Add task")
        .padding(.trailing, Spacing.xxl)
        .padding(.bottom, fabBottomPad)
    }
}

// MARK: - Preview

#Preview {
    TodayView()
}
