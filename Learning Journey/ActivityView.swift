//
//  ActivityView.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//
import SwiftUI
import UIKit

struct ActivityView: View {
    private var currentDayStatus: DayStatus {
        let day = Calendar.current.startOfDay(for: currentDate)
        return viewModel.dailyLogs[day] ?? .notLogged
    }

    private var canFreezeToday: Bool {
        currentDayStatus == .notLogged &&
        viewModel.freezesRemaining > 0
    }
    @Bindable var viewModel: LearningViewModel
    @State private var currentDate = Date()
    @State private var showNewGoal = false
    private var result: LearningViewModel.GoalResult {
        viewModel.goalResult(at: currentDate)
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            HStack(alignment: .center) {
                Text("Activity")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                NavigationLink {
                    ActivitiesView(dailyLogs: viewModel.dailyLogs)                } label: {
                        Image(systemName: "calendar")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .glassEffect(.regular, in: Circle())
                    }
                
                NavigationLink {
                    UpdateLearningGoalView(viewModel: viewModel)
                } label: {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .glassEffect(.regular, in: Circle())
                }
            }
                
            Text(currentDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))                .font(.system(size: 16))
                .foregroundStyle(.gray)
                
                WeeklyCalendarView(dailyLogs: viewModel.dailyLogs)
                
                HStack(spacing: 12) {
                    ActivityStatCard(
                        icon: "flame.fill",
                        count: viewModel.currentStreak(),
                        title: "Learned",
                        color: .orange
                    )
                    
                    ActivityStatCard(
                        icon: "snowflake",
                        count: viewModel.frozenDays,
                        title: "Freezed",
                        color: .cyan
                    )
                }
                
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
                .navigationDestination(isPresented: $showNewGoal) {
                    UpdateLearningGoalView(
                        viewModel: viewModel,
                        isNewGoal: true
                    )
                }
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
                }
                
            }
        }

#Preview {
    NavigationStack {
        ActivityView(viewModel: LearningViewModel())
            .preferredColorScheme(.dark)
    }
}
    
