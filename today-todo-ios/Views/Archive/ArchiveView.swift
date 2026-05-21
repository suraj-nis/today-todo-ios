import SwiftUI

// MARK: - Archive color scheme

/// Bundles the five colors that differ between morning/midday and evening.
/// Computed once in ArchiveView and passed to every ArchiveDaySection.
struct ArchiveColorScheme {
    let kickerColor: Color
    let subtitleColor: Color
    let circleBorderColor: Color
    let dateLabelColor: Color
    let mutedTitleColor: Color

    static func make(for timeOfDay: TimeOfDay) -> ArchiveColorScheme {
        switch timeOfDay {
        case .evening:
            return ArchiveColorScheme(
                kickerColor:       Color.archiveCircleFill,           // #9c5851
                subtitleColor:     Color.archiveEveningSubtitle,      // #6e2e2e
                circleBorderColor: Color.archiveCircleFill,        // #9c5851
                dateLabelColor:    Color.archiveCircleFill,           // #9c5851
                mutedTitleColor:   Color.archiveCircleFill            // #9c5851
            )
        case .morning, .midday:
            return ArchiveColorScheme(
                kickerColor:       Color.archiveInkRose,              // #a08585
                subtitleColor:     Color.archiveInkWarm,              // #6b4a30
                circleBorderColor: Color.archiveMornBorder,           // #d4c2a8
                dateLabelColor:    Color.archiveDateLabel,            // #a08568
                mutedTitleColor:   Color.archiveInkRose.opacity(0.55) // #a08585 @ 55%
            )
        }
    }
}

// MARK: - View

struct ArchiveView: View {

    let timeOfDay: TimeOfDay

    @State private var viewModel = ArchiveViewModel()

    private var colors: ArchiveColorScheme {
        .make(for: timeOfDay)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer
                scrollLayer
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        timeOfDayGradient.ignoresSafeArea()
    }

    private var timeOfDayGradient: LinearGradient {
        switch timeOfDay {
        case .morning: return .todayMorning
        case .midday:  return .todayMidday
        case .evening: return .todaySunset
        }
    }

    // MARK: - Scrollable content

    private var scrollLayer: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.sm)
                    .padding(.bottom, Spacing.s3)

                ForEach(viewModel.archivedDays) { day in
                    ArchiveDaySection(day: day, colors: colors) {
                        viewModel.deleteDay(day)
                    }
                    .padding(.horizontal, Spacing.lg)
                }

                Color.clear
                    .frame(height: AppConstants.tabBarHeight + Spacing.xl)
            }
            .padding(.top, Spacing.lg)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("WHAT'S BEEN")
                .font(.todayCaption)
                .foregroundStyle(colors.kickerColor)
                .tracking(1.4)

            Text("Archive.")
                .font(.todayScreenTitle)
                .foregroundStyle(Color.archiveInkDark)
                .tracking(-0.6)
                .padding(.top, Spacing.xs)

            Text("Days that have passed.")
                .font(.archiveSubtitle)
                .foregroundStyle(colors.subtitleColor)
                .tracking(-0.2)
                .padding(.top, Spacing.xs)
        }
    }
}

// MARK: - Preview

#Preview("Morning") {
    ArchiveView(timeOfDay: .morning)
}

#Preview("Midday") {
    ArchiveView(timeOfDay: .midday)
}

#Preview("Evening") {
    ArchiveView(timeOfDay: .evening)
}
