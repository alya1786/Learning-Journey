
import SwiftUI
import UIKit

struct ActivityView: View {
    
    @Bindable var viewModel: LearningViewModel
    
    @State private var currentDate = Date()
    @State private var showNewGoal = false
    @State private var showUpdateGoal = false
    
#if DEBUG
    @State private var testResult: LearningViewModel.GoalResult?
#endif
    
    // MARK: - Today's Activity
    
    private var currentDayStatus: DayStatus {
        let day = Calendar.current.startOfDay(for: currentDate)
        return viewModel.currentGoalLogs[day] ?? .notLogged
    }
    
    private var canFreezeToday: Bool {
        viewModel.canFreeze
    }
    
    
    
    private var result: LearningViewModel.GoalResult {
#if DEBUG
        if let testResult {
            return testResult
        }
#endif
        
        return viewModel.goalResult(at: currentDate)
    }
    
    // MARK: - Body
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: Header
            
            HStack(alignment: .center) {
                
                Text("Activity")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Calendar button
                NavigationLink {
                    ActivitiesView(dailyLogs: viewModel.dailyLogs)
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .glassEffect(.regular, in: Circle())
                }
                
                // Update goal button
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
            
            // MARK: Current Date
            
            Text(
                currentDate.formatted(
                    .dateTime.weekday(.wide).day().month(.wide)
                )
            )
            .font(.system(size: 16))
            .foregroundStyle(.gray)
            
            // MARK: Weekly Calendar
            
            WeeklyCalendarView(
                dailyLogs: viewModel.dailyLogs
            )
            
            // MARK: Activity Statistics
            
            HStack(spacing: 12) {
                
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    ActivityStatCard(
                        icon: "flame.fill",
                        count: viewModel.currentStreak(at: context.date),
                        title: "Learned",
                        color: .orange
                    )
                }
                
                
                ActivityStatCard(
                    icon: "snowflake",
                    count: viewModel.frozenDays,
                    title: "Freezed",
                    color: .cyan
                )
            }
            //#if DEBUG
            //HStack(spacing: 12) {
            //  Button("Test Success") {
            //   testResult = .completed
            // }
            
            //  Button("Test Failure") {
            //       testResult = .notMet
            // }
            
            //Button("Reset") {
            //     testResult = nil
            //  }
            //}
            //.font(.system(size: 12))
            //.buttonStyle(.bordered)
            //#endif
            // MARK: Daily Actions / Goal Result
            
            if result == .inProgress {
                
                Spacer(minLength: 24)
                
                DailyActionButtons(
                    status: currentDayStatus,
                    canFreeze: canFreezeToday,
                    freezesUsed: viewModel.frozenDays,
                    freezeLimit: viewModel.freezeLimit,
                    onLearned: {
                        viewModel.logToday(as: .learned)
                    },
                    onFreeze: {
                        viewModel.logToday(as: .frozen)
                    }
                )
                .padding(.bottom, 32)
                
            } else {
                
                GoalResultView(
                    result: result,
                    onSetGoal: {
                        showNewGoal = true
                    }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .background(Color.black)
        .toolbar(.hidden, for: .navigationBar)
        
        // MARK: Update Goal Sheet
        
        .sheet(isPresented: $showUpdateGoal) {
            UpdateLearningGoalView(viewModel: viewModel)
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
