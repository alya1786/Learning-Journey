import Foundation
import SwiftUI

// MARK: - Activity View

struct ActivityView: View {

    // App data.
    @Bindable var viewModel: LearningViewModel

    // Track when the app becomes active.
    @Environment(\.scenePhase) private var scenePhase

    // Restart the scheduled update when needed.
    @State private var scheduleID = UUID()

    // Current date.
    @State private var currentDate = Date()

    // Sheet controls.
    @State private var showNewGoal = false
    @State private var showUpdateGoal = false

    // MARK: - Body

    var body: some View {

        Group {

            let liveDate = currentDate

            // Check the goal result.
            let liveResult = viewModel.goalResult(
                at: liveDate
            )

            // Find today's activity.
            let today = Calendar.current.startOfDay(
                for: liveDate
            )

            let liveDayStatus =
                viewModel.currentGoalLogs[today]
                ?? .notLogged

            // Check if the goal is finished.
            let isFinished = liveResult != .inProgress

            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Header

                HStack(alignment: .center) {

                    // Page title.
                    Text("Activity")
                        .font(
                            .system(
                                size: 34,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.white)

                    Spacer()

                    // Open the full calendar.
                    NavigationLink {
                        ActivitiesView(
                            dailyLogs: viewModel.dailyLogs
                        )
                    } label: {
                        Image(systemName: "calendar")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .glassEffect(
                                .regular,
                                in: Circle()
                            )
                    }

                    // Open the goal editor.
                    Button {
                        showUpdateGoal = true
                    } label: {
                        Image(
                            systemName: "pencil.and.outline"
                        )
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .glassEffect(
                            .regular,
                            in: Circle()
                        )
                    }
                    .buttonStyle(.plain)
                }

                // MARK: - Current Date

                // Show today's date.
                Text(
                    currentDate.formatted(
                        .dateTime
                            .weekday(.wide)
                            .day()
                            .month(.wide)
                    )
                )
                .font(.system(size: 16))
                .foregroundStyle(.gray)

                // MARK: - Weekly Calendar

                // Show this week's activity.
                WeeklyCalendarView(
                    dailyLogs: viewModel.dailyLogs,
                    currentDate: currentDate
                )
                // MARK: - Activity Statistics

                HStack(spacing: 12) {

                    // Show the current streak.
                    ActivityStatCard(
                        icon: "flame.fill",
                        count: viewModel.currentStreak(
                            at: liveDate
                        ),
                        title: "Learned",
                        color: .orange
                    )

                    // Show used freezes.
                    ActivityStatCard(
                        icon: "snowflake",
                        count: isFinished
                            ? 0
                            : viewModel.frozenDays,
                        title: "Freezed",
                        color: .cyan
                    )
                }

                // MARK: - Daily Actions

                if liveResult == .inProgress {

                    Spacer(minLength: 24)

                    // Learned and Freeze buttons.
                    DailyActionButtons(
                        status: liveDayStatus,
                        canFreeze: viewModel.canFreeze,
                        freezesUsed: viewModel.frozenDays,
                        freezeLimit: viewModel.freezeLimit,
                        onLearned: {
                            viewModel.logToday(
                                as: .learned
                            )
                        },
                        onFreeze: {
                            viewModel.logToday(
                                as: .frozen
                            )
                        }
                    )
                    .padding(.bottom, 32)

                } else {

                    // MARK: - Goal Result

                    // Show the final goal result.
                    GoalResultView(
                        result: liveResult,
                        onSetGoal: {
                            showNewGoal = true
                        }
                    )
                }
            }

            // MARK: - Layout

            .padding(.horizontal, 16)
            .padding(.top, 24)

            // Keep the background dark.
            .background(
                Color.black.ignoresSafeArea()
            )
            .foregroundStyle(.white)
           .preferredColorScheme(.dark)
            .toolbar(
                .hidden,
                for: .navigationBar
            )

            // MARK: - Update Goal Sheet

            // Open the edit goal screen.
            .sheet(isPresented: $showUpdateGoal) {
                UpdateLearningGoalView(
                    viewModel: viewModel
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.black)
                .preferredColorScheme(.dark)
            }

            // MARK: - New Goal Sheet

            // Open the new goal screen.
            .sheet(isPresented: $showNewGoal) {
                UpdateLearningGoalView(
                    viewModel: viewModel,
                    isNewGoal: true
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.black)
                .preferredColorScheme(.dark)
            }

            // MARK: - Date Updates

            // Refresh when the app becomes active.
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    refresh()
                    scheduleID = UUID()
                }
            }

            // Restart after logging an activity.
            .onChange(of: viewModel.lastLogDate) { _, _ in
                refresh()
                scheduleID = UUID()
            }

            // Restart after changing the goal.
            .onChange(of: viewModel.currentGoal?.startDate) { _, _ in
                refresh()
                scheduleID = UUID()
            }

            // Wait until the next important event.
            .task(id: scheduleID) {
                refresh()

                while !Task.isCancelled {
                    let now = Date()
                    let next = nextUpdateDate(after: now)

                    let seconds = max(
                        0.1,
                        next.timeIntervalSince(now)
                    )

                    do {
                        try await Task.sleep(
                            for: .seconds(seconds)
                        )
                    } catch {
                        break
                    }

                    guard !Task.isCancelled else {
                        break
                    }

                    refresh()
                }
            }

        } // End Group.

    } // End body.

    // MARK: - Helpers

    // Refresh the date and streak.
    private func refresh() {
        currentDate = Date()
        viewModel.refreshStreak(at: currentDate)
    }

    // Find the next time-sensitive event.
    private func nextUpdateDate(after now: Date) -> Date {
        let calendar = Calendar.current

        // Next midnight.
        let tomorrow = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: now)
        ) ?? now.addingTimeInterval(86_400)

        var nextDate = tomorrow

        // Check the 32-hour deadline.
        if let lastLog = viewModel.lastLogDate {
            let deadline = lastLog.addingTimeInterval(
                32 * 60 * 60
            )

            if deadline > now {
                nextDate = min(nextDate, deadline)
            }
        }

        // Check when the goal ends.
        if let goal = viewModel.currentGoal {
            let goalEnd = calendar.startOfDay(
                for: goal.endDate
            )

            if goalEnd > now {
                nextDate = min(nextDate, goalEnd)
            }
        }

        return nextDate
    }

} // End ActivityView.

// MARK: - Preview

#Preview {
    NavigationStack {
        ActivityView(
            viewModel: LearningViewModel()
        )
      .preferredColorScheme(.dark)
    }
}
