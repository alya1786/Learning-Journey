
import SwiftUI
import UIKit

struct ActivityView: View {

    @Bindable var viewModel: LearningViewModel

    @State private var currentDate = Date()
    @State private var showNewGoal = false
    @State private var showUpdateGoal = false

    // MARK: - Body

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            // MARK: - Header

            HStack(alignment: .center) {

                Text("Activity")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                // Calendar button

                NavigationLink {
                    ActivitiesView(
                        dailyLogs: viewModel.dailyLogs
                    )
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .glassEffect(.regular, in: Circle())
                }

                // Update Goal button

                Button {
                    showUpdateGoal = true
                } label: {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .glassEffect(.regular, in: Circle())
                }
                .buttonStyle(.plain)
            }

            // MARK: - Current Date

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

            WeeklyCalendarView(
                dailyLogs: viewModel.dailyLogs
            )

            // MARK: - Activity Statistics

            HStack(spacing: 12) {

                // Learned / Streak

                TimelineView(
                    .periodic(from: .now, by: 1)
                ) { context in
                    ActivityStatCard(
                        icon: "flame.fill",
                        count: viewModel.currentStreak(
                            at: context.date
                        ),
                        title: "Learned",
                        color: .orange
                    )
                }

                // Freeze

                TimelineView(
                    .periodic(from: .now, by: 1)
                ) { context in
                    let isFinished =
                        viewModel.goalResult(
                            at: context.date
                        ) != .inProgress

                    ActivityStatCard(
                        icon: "snowflake",
                        count: isFinished
                            ? 0
                            : viewModel.frozenDays,
                        title: "Freezed",
                        color: .cyan
                    )
                }
            }

            // MARK: - Daily Actions / Goal Result

            TimelineView(
                .periodic(from: .now, by: 1)
            ) { context in

                let liveDate = context.date

                let liveResult: LearningViewModel.GoalResult =
                    viewModel.goalResult(at: liveDate)

                let today = Calendar.current.startOfDay(
                    for: liveDate
                )

                let liveDayStatus =
                    viewModel.currentGoalLogs[today]
                    ?? .notLogged

                Group {

                    if liveResult == .inProgress {

                        Spacer(minLength: 24)

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

                        GoalResultView(
                            result: liveResult,
                            onSetGoal: {
                                showNewGoal = true
                            }
                        )
                    }
                }
            }
        }

        // MARK: - Layout

        .padding(.horizontal, 16)
        .padding(.top, 24)
        .background(Color.black)
        .toolbar(.hidden, for: .navigationBar)

        // MARK: - Update Goal Sheet

        .sheet(isPresented: $showUpdateGoal) {

            UpdateLearningGoalView(
                viewModel: viewModel
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.black)
        }

        // MARK: - New Goal Sheet

        .sheet(isPresented: $showNewGoal) {

            UpdateLearningGoalView(
                viewModel: viewModel,
                isNewGoal: true
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.black)
        }

        // MARK: - Refresh Date

        .onReceive(
            NotificationCenter.default.publisher(
                for: .NSCalendarDayChanged
            )
        ) { _ in
            currentDate = Date()
            viewModel.refreshStreak()
        }

        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification
            )
        ) { _ in
            currentDate = Date()
            viewModel.refreshStreak()
        }
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {

        ActivityView(
            viewModel: LearningViewModel()
        )
        .preferredColorScheme(.dark)
    }
}
