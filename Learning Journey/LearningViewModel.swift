//
//  LearningViewModel.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//

import Foundation
import Observation

@Observable
class LearningViewModel{
    var learningTitle = ""
    var selectedDuration : GoalDuration = .Week
    var currentGoal : LearningGoal?
    var canStart: Bool{
        !learningTitle
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    init() {
        if let saved = LearningStorage.load() {
            currentGoal = saved.goal
            learningTitle = saved.goal.title
            selectedDuration = saved.goal.duration
            dailyLogs = saved.dailyLogs
            streak = saved.streak
            lastLogDate = saved.lastLogDate
            logTimestamps = saved.logTimestamps

            saveProgress()
        }
    }

    private func saveProgress() {
        guard let currentGoal else { return }

        let data = SavedLearningData(
            goal: currentGoal,
            dailyLogs: dailyLogs,
            streak: streak,
            lastLogDate: lastLogDate,
            logTimestamps: logTimestamps
        )

        LearningStorage.save(data)
    }
    
    func startLearning() {
        let cleanTitle = learningTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanTitle.isEmpty{
            let newGoal = LearningGoal(
                title: cleanTitle,
                duration: selectedDuration)
            currentGoal = newGoal
            saveProgress()
            print("Saved goal:", currentGoal as Any)
            
        }
    }
    var dailyLogs: [Date: DayStatus] = [:]
    var logTimestamps: [Date: Date] = [:]
    var lastLogDate: Date?
    var streak: Int = 0
    
    var learnedDays: Int {
        dailyLogs.values.filter { $0 == .learned }.count
    }
    
    var frozenDays: Int {
        dailyLogs.values.filter { $0 == .frozen }.count
    }
    
    var freezeLimit: Int {
        switch currentGoal?.duration {
        case .Week:
            return 2
        case .Month:
            return 8
        case .Year:
            return 96
        case nil:
            return 0
        }
    
    }
    
    
    var freezesRemaining: Int {
        max(0, freezeLimit - frozenDays)
    }
    
    var canFreeze: Bool {
        todayStatus == .notLogged && freezesRemaining > 0
    }
    
    var todayStatus: DayStatus {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyLogs[today] ?? .notLogged
    }
    
    func logToday(as status: DayStatus) {
        guard isGoalActive else { return }
        guard status != .notLogged else { return }

        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        guard dailyLogs[today] == nil else { return }

        if status == .frozen {
            guard canFreeze else { return }
        }

            if let lastLogDate {
            let hoursPassed = now.timeIntervalSince(lastLogDate) / 3600

            let previousDay = calendar.startOfDay(for: lastLogDate)
            let daysApart = calendar.dateComponents(
                [.day],
                from: previousDay,
                to: today
            ).day ?? 0

            if hoursPassed > 32 || daysApart != 1 {
                streak = 0
            }
        } else {
            streak = 0
        }

        // Learned increases the streak; Freeze preserves it
        if status == .learned {
            streak += 1
        }

        dailyLogs[today] = status
        logTimestamps[today] = now
        lastLogDate = now

        saveProgress()
    }
    func updateGoal(title: String, duration: GoalDuration) {
        let cleanTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTitle.isEmpty else { return }


        if let currentGoal,
           currentGoal.title == cleanTitle,
           currentGoal.duration == duration {
            return
        }

        currentGoal = LearningGoal(
            title: cleanTitle,
            duration: duration
        )

        learningTitle = cleanTitle
        selectedDuration = duration

  
        dailyLogs = [:]
        logTimestamps = [:]
        streak = 0
        lastLogDate = nil
        saveProgress()
    }
    
    func currentStreak(at date: Date = Date()) -> Int {
        guard currentGoal != nil,
              let lastLogDate else {
            return 0
        }

        let hoursPassed = date.timeIntervalSince(lastLogDate) / 3600

        if hoursPassed > 32 {
            return 0
        }

        return streak
    }
    
    enum GoalResult {
        case inProgress
        case completed
        case notMet
    }
   
    func goalResult(at date: Date = Date()) -> GoalResult {
        guard let goal = currentGoal else {
            return .inProgress
        }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: goal.startDate)
        let end = calendar.startOfDay(for: goal.endDate)
        let today = calendar.startOfDay(for: date)

        let requiredDays = calendar.dateComponents(
            [.day],
            from: start,
            to: end
        ).day ?? 0

        let completedDays = dailyLogs.filter { day, status in
            let loggedDay = calendar.startOfDay(for: day)

            return status != .notLogged &&
                   loggedDay >= start &&
                   loggedDay < end
        }.count

        if completedDays >= requiredDays {
            return .completed
        }

        if today < end {
            return .inProgress
        }

        return .notMet
    }
    
    var isGoalActive: Bool {
        guard let goal = currentGoal else {
            return false
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let endDay = calendar.startOfDay(for: goal.endDate)

        return today < endDay
    }

    var extendedEndDate: Date? {
        currentGoal?.endDate
    }

    func resetForNewGoal() {
        LearningStorage.clear()

        currentGoal = nil
        learningTitle = ""
        selectedDuration = .Week

        dailyLogs = [:]
        streak = 0
        lastLogDate = nil
    }
    func startNewGoal(title: String, duration: GoalDuration) {
        let cleanTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTitle.isEmpty else { return }

        dailyLogs = [:]
        streak = 0
        lastLogDate = nil
        logTimestamps = [:]

        learningTitle = cleanTitle
        selectedDuration = duration

        currentGoal = LearningGoal(
            title: cleanTitle,
            duration: duration,
            startDate: Date()
        )

        saveProgress()
    }
}
