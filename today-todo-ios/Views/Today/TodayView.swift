import SwiftUI

struct TodayView: View {

    @State private var viewModel: TodayViewModel
    @State private var isAddingTask = false

    init(viewModel: TodayViewModel = TodayViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }

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
            AddTaskSheetView(viewModel: viewModel)
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        viewModel.timeOfDayGradient
            .ignoresSafeArea()
    }

    // MARK: - Scrollable content

    private var scrollLayer: some View {
        List {
            headerSection
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.md)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())

            if viewModel.sortedTodayTasks.isEmpty {
                emptyContent
                    .frame(minHeight: 480)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
            } else {
                ForEach(viewModel.sortedTodayTasks) { task in
                    TaskRowView(task: task, timeOfDay: viewModel.timeOfDay,
                               isExpired: viewModel.isTaskExpired(task)) {
                        withAnimation(.circleComplete) {
                            viewModel.toggleComplete(task)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation(.rowDelete) {
                                viewModel.deleteTask(task)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(
                        top: 0, leading: -Spacing.md,
                        bottom: 0, trailing: 0))
                }
            }

#if DEBUG
            debugButton
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
#endif

            Color.clear
                .frame(height: fabSize + fabBottomPad + AppConstants.tabBarHeight)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .padding(.top, Spacing.lg)
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

    // MARK: - Debug

#if DEBUG
    private var debugButton: some View {
        Button("Simulate Day Reset") {
            viewModel.simulateDayReset(daysAgo: 1)
        }
        .font(.caption)
        .foregroundStyle(Color.accent)
        .padding()
    }
#endif

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
