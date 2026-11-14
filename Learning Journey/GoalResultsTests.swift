//
//  GoalResultsTests.swift
//  Learning Journey
//
//  Created by alya alansari on 14/11/2026.
//


import Foundation

#if DEBUG

enum GoalResultTests {

    static func run() {
        let calendar = Calendar.current

        guard let startDate = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 11,
                day: 14,
                hour: 12
            )
        ) else { return }

        let model = LearningViewModel()
        // Isolate the test from saved streak data
        model.lastLogDate = nil
        model.streak = 0

        model.currentGoal = LearningGoal(
            title: "Test Goal",
            duration: .Week,
            startDate: startDate
        )

        model.currentGoalLogs = [:]

        // Log all seven days: 6 Learned + 1 Freeze
        for day in 0..<7 {
            guard let date = calendar.date(
                byAdding: .day,
                value: day,
                to: calendar.startOfDay(for: startDate)
            ) else { continue }

            model.currentGoalLogs[date] =
                day == 2 ? .frozen : .learned
        }

        let beforeDeadline = calendar.date(
            byAdding: .day,
            value: 6,
            to: startDate
        )!

        let afterDeadline = calendar.date(
            byAdding: .day,
            value: 7,
            to: startDate
        )!

        assert(
            model.goalResult(at: beforeDeadline) == .inProgress,
            "Goal should still be in progress"
        )

        assert(
            model.goalResult(at: afterDeadline) == .completed,
            "Goal should be completed"
        )

        // Remove one logged day
        let missedDay = calendar.date(
            byAdding: .day,
            value: 4,
            to: calendar.startOfDay(for: startDate)
        )!

        model.currentGoalLogs.removeValue(forKey: missedDay)

        assert(
            model.goalResult(at: afterDeadline) == .notMet,
            "Goal should not be met"
        )
        // MARK: - Streak Expiration Test

        let streakModel = LearningViewModel()

        let lastActivity = Date(
            timeIntervalSince1970: 1_700_000_000
        )

        streakModel.currentGoal = LearningGoal(
            title: "Streak Test",
            duration: .Week,
            startDate: lastActivity
        )

        streakModel.streak = 5
        streakModel.lastLogDate = lastActivity

        let before32Hours = lastActivity.addingTimeInterval(
            31 * 60 * 60
        )

        let exactly32Hours = lastActivity.addingTimeInterval(
            32 * 60 * 60
        )

        assert(
            streakModel.currentStreak(at: before32Hours) == 5,
            "Streak should remain active before 32 hours"
        )

        assert(
            streakModel.currentStreak(at: exactly32Hours) == 0,
            "Streak should expire at exactly 32 hours"
        )
        // MARK: - Goal Failure After 32 Hours

        let failureModel = LearningViewModel()

        let firstDay = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 11,
                day: 14
            )
        )!
        
        // Create a weekly goal
        failureModel.currentGoal = LearningGoal(
            title: "Failure Test",
            duration: .Week,
            startDate: firstDay
        )

        // Simulate a Learned log
        failureModel.currentGoalLogs = [
            firstDay: .learned
        ]

        failureModel.dailyLogs = [
            firstDay: .learned
        ]

        failureModel.streak = 1
        failureModel.lastLogDate = firstDay

        // Check before 32 hours
        let beforeExpiration = firstDay.addingTimeInterval(
            31 * 60 * 60
        )

        // Check at exactly 32 hours
        let atExpiration = firstDay.addingTimeInterval(
            32 * 60 * 60
        )

        assert(
            failureModel.goalResult(at: beforeExpiration) == .inProgress,
            "Goal should still be active before 32 hours"
        )

        assert(
            failureModel.goalResult(at: atExpiration) == .notMet,
            "Goal should fail immediately after 32 hours"
        )

        // Verify historical logs are preserved
        assert(
            failureModel.dailyLogs[firstDay] == .learned,
            "Historical Learned log should remain saved"
        )

        assert(
            failureModel.currentGoalLogs[firstDay] == .learned,
            "Current goal logs should remain unchanged"
        )
        
        // MARK: - Exact 32-Hour Deadline Test

        let deadlineModel = LearningViewModel(
            loadSavedData: false
        )

        let testStart = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 11,
                day: 14,
                hour: 20
            )
        )!

        deadlineModel.currentGoal = LearningGoal(
            title: "32-Hour Test",
            duration: .Week,
            startDate: testStart
        )

        deadlineModel.logToday(
            as: .learned,
            at: testStart
        )

        let beforeExpiry = testStart.addingTimeInterval(
            32 * 60 * 60 - 1
        )

        let exactExpiry = testStart.addingTimeInterval(
            32 * 60 * 60
        )

        // Before 32 hours: goal remains active
        assert(
            deadlineModel.goalResult(at: beforeExpiry)
                == .inProgress,
            "Goal should remain active one second before 32 hours"
        )

        // Exactly 32 hours: goal fails
        assert(
            deadlineModel.goalResult(at: exactExpiry)
                == .notMet,
            "Goal should fail at exactly 32 hours"
        )

        // Previous Learned log must remain
        let loggedDay = calendar.startOfDay(
            for: testStart
        )

        assert(
            deadlineModel.dailyLogs[loggedDay] == .learned,
            "Previous Learned log must remain in calendar"
        )

        print("✅ Exact 32-hour deadline test passed!")

        // MARK: - Freeze Renews 32-Hour Window

        let freezeModel = LearningViewModel(
            loadSavedData: false
        )

        let firstLog = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 11,
                day: 14,
                hour: 20
            )
        )!

        freezeModel.currentGoal = LearningGoal(
            title: "Freeze Test",
            duration: .Week,
            startDate: firstLog
        )

        // Day 1: Learned at 8 PM
        freezeModel.logToday(
            as: .learned,
            at: firstLog
        )

        // Day 2: Freeze at midnight
        let freezeTime = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: firstLog)
        )!

        freezeModel.logToday(
            as: .frozen,
            at: freezeTime
        )

        assert(
            freezeModel.streak == 1,
            "Freeze must not increase the streak"
        )

        assert(
            freezeModel.frozenDays == 1,
            "Freeze should be recorded"
        )

        assert(
            freezeModel.lastLogDate == freezeTime,
            "Freeze should renew the 32-hour window"
        )

        let beforeFreezeExpiry = freezeTime.addingTimeInterval(
            32 * 60 * 60 - 1
        )

        let freezeExpiry = freezeTime.addingTimeInterval(
            32 * 60 * 60
        )

        assert(
            freezeModel.goalResult(at: beforeFreezeExpiry)
                == .inProgress,
            "Goal should remain active before freeze expires"
        )

        assert(
            freezeModel.goalResult(at: freezeExpiry)
                == .notMet,
            "Goal should fail 32 hours after freeze"
        )

        assert(
            freezeModel.dailyLogs[
                calendar.startOfDay(for: firstLog)
            ] == .learned,
            "Learned history must remain"
        )

        assert(
            freezeModel.dailyLogs[
                calendar.startOfDay(for: freezeTime)
            ] == .frozen,
            "Freeze history must remain"
        )

        print("✅ Freeze renewal test passed!")

        print("✅ All Goal Result tests passed!")
    }
}

#endif
