//  GoalResultsTests.swift
//  Learning Journey
//
//  Created by alya alansari on 14/11/2026.
//

import Foundation

#if DEBUG

enum GoalResultTests {

    // Run all goal tests.
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

        // Use test data only.
        let model = LearningViewModel(loadSavedData: false)
        model.lastLogDate = nil
        model.streak = 0

        model.currentGoal = LearningGoal(
            title: "Test Goal",
            duration: .Week,
            startDate: startDate
        )

        model.currentGoalLogs = [:]

        // Log seven days: six learned and one frozen.
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

        // Remove one logged day.
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

        let streakModel = LearningViewModel(
            loadSavedData: false
        )

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

        let failureModel = LearningViewModel(
            loadSavedData: false
        )

        let firstDay = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 11,
                day: 14
            )
        )!

        // Create a weekly goal.
        failureModel.currentGoal = LearningGoal(
            title: "Failure Test",
            duration: .Week,
            startDate: firstDay
        )

        // Simulate a learned day.
        failureModel.currentGoalLogs = [
            firstDay: .learned
        ]

        failureModel.dailyLogs = [
            firstDay: .learned
        ]

        failureModel.streak = 1
        failureModel.lastLogDate = firstDay

        let beforeExpiration = firstDay.addingTimeInterval(
            31 * 60 * 60
        )

        let atExpiration = firstDay.addingTimeInterval(
            32 * 60 * 60
        )

        // Check before the deadline.
        assert(
            failureModel.goalResult(at: beforeExpiration) == .inProgress,
            "Goal should still be active before 32 hours"
        )

        // Check at the deadline.
        assert(
            failureModel.goalResult(at: atExpiration) == .notMet,
            "Goal should fail immediately after 32 hours"
        )

        // Keep previous activity.
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

        // Check one second before expiration.
        assert(
            deadlineModel.goalResult(at: beforeExpiry)
                == .inProgress,
            "Goal should remain active one second before 32 hours"
        )

        // Check exact expiration.
        assert(
            deadlineModel.goalResult(at: exactExpiry)
                == .notMet,
            "Goal should fail at exactly 32 hours"
        )

        // Keep the learned day in history.
        let loggedDay = calendar.startOfDay(
            for: testStart
        )

        assert(
            deadlineModel.dailyLogs[loggedDay] == .learned,
            "Previous Learned log must remain in calendar"
        )

        // Run the remaining tests.
        testCompletedGoal()
        testFailedGoal()
        testNewGoal()

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

        // Day 1: Log as learned.
        freezeModel.logToday(
            as: .learned,
            at: firstLog
        )

        // Day 2: Use a freeze.
        let freezeTime = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: firstLog)
        )!

        freezeModel.logToday(
            as: .frozen,
            at: freezeTime
        )

        // Freeze does not increase the streak.
        assert(
            freezeModel.streak == 1,
            "Freeze must not increase the streak"
        )

        assert(
            freezeModel.frozenDays == 1,
            "Freeze should be recorded"
        )

        // Freeze starts a new 32-hour window.
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

        // Keep learned and frozen days in history.
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
        
        // MARK: - Logging at the 32-Hour Boundary

        let boundaryStart = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 11,
                day: 14,
                hour: 20
            )
        )!

        let boundaryDeadline = boundaryStart.addingTimeInterval(
            32 * 60 * 60
        )

        // Test 1: Log one second before expiration.
        let beforeModel = LearningViewModel(
            loadSavedData: false
        )

        beforeModel.currentGoal = LearningGoal(
            title: "Before Deadline Test",
            duration: .Week,
            startDate: boundaryStart
        )

        beforeModel.logToday(
            as: .learned,
            at: boundaryStart
        )

        let oneSecondBefore = boundaryDeadline.addingTimeInterval(-1)

        beforeModel.logToday(
            as: .learned,
            at: oneSecondBefore
        )

        let beforeDay = calendar.startOfDay(
            for: oneSecondBefore
        )

        assert(
            beforeModel.currentGoalLogs[beforeDay] == .learned,
            "Logging should be allowed one second before expiration"
        )

        assert(
            beforeModel.lastLogDate == oneSecondBefore,
            "Successful logging should renew the 32-hour window"
        )

        print("✅ Logging before deadline test passed!")

        // Test 2: Try logging one second after expiration.
        let afterModel = LearningViewModel(
            loadSavedData: false
        )

        afterModel.currentGoal = LearningGoal(
            title: "After Deadline Test",
            duration: .Week,
            startDate: boundaryStart
        )

        afterModel.logToday(
            as: .learned,
            at: boundaryStart
        )

        let oneSecondAfter = boundaryDeadline.addingTimeInterval(1)

        afterModel.logToday(
            as: .learned,
            at: oneSecondAfter
        )

        let afterDay = calendar.startOfDay(
            for: oneSecondAfter
        )

        assert(
            afterModel.currentGoalLogs[afterDay] == nil,
            "Logging must be rejected after expiration"
        )

        assert(
            afterModel.lastLogDate == boundaryStart,
            "Rejected logging must not renew the deadline"
        )

        print("✅ Logging after deadline test passed!")


        // MARK: - Midnight Boundary Tests

        let midnightModel = LearningViewModel(
            loadSavedData: false
        )

        let midnightStart = calendar.date(
            from: DateComponents(
                year: 2026,
                month: 11,
                day: 14,
                hour: 12
            )
        )!

        midnightModel.currentGoal = LearningGoal(
            title: "Midnight Test",
            duration: .Week,
            startDate: midnightStart
        )

        // Simulate seven completed days.
        for day in 0..<7 {
            let date = calendar.date(
                byAdding: .day,
                value: day,
                to: calendar.startOfDay(for: midnightStart)
            )!

            midnightModel.currentGoalLogs[date] = .learned
        }

        // Midnight after the final goal day.
        let finalMidnight = calendar.startOfDay(
            for: midnightModel.currentGoal!.endDate
        )

        let oneSecondBeforeMidnight = finalMidnight
            .addingTimeInterval(-1)

        // Test 1: Goal stays active before midnight.
        assert(
            midnightModel.goalResult(
                at: oneSecondBeforeMidnight
            ) == .inProgress,
            "Goal should remain active before final midnight"
        )

        print("✅ Before midnight test passed!")

        // Test 2: Goal completes at exactly midnight.
        assert(
            midnightModel.goalResult(
                at: finalMidnight
            ) == .completed,
            "Goal should complete at final midnight"
        )

        print("✅ At midnight test passed!")

        // Test 3: Missing one day causes failure.
        let missingDay = calendar.date(
            byAdding: .day,
            value: 3,
            to: calendar.startOfDay(for: midnightStart)
        )!

        midnightModel.currentGoalLogs.removeValue(
            forKey: missingDay
        )

        assert(
            midnightModel.goalResult(
                at: finalMidnight
            ) == .notMet,
            "Goal should fail at midnight if a day is missing"
        )

        print("✅ Midnight failure test passed!")

        print("✅ Freeze renewal test passed!")
        print("✅ All Goal Result tests passed!")
    }

    // MARK: - Failed Goal Test

    // Check a goal with a missing day.
    static func testFailedGoal() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())

        let model = LearningViewModel(
            loadSavedData: false
        )

        model.currentGoal = LearningGoal(
            title: "Failed Test Goal",
            duration: .Week,
            startDate: start
        )

        // Log only six days.
        for day in 0..<6 {
            let date = calendar.date(
                byAdding: .day,
                value: day,
                to: start
            )!

            model.currentGoalLogs[date] = .learned
            model.dailyLogs[date] = .learned
        }

        model.streak = 6
        model.lastLogDate = calendar.date(
            byAdding: .day,
            value: 5,
            to: start
        )

        // Check the final deadline.
        let deadline = calendar.date(
            byAdding: .day,
            value: 7,
            to: start
        )!

        assert(
            model.goalResult(at: deadline) == .notMet,
            "Incomplete goal should fail at midnight"
        )

        assert(
            model.currentStreak(at: deadline) == 0,
            "Streak should be zero after failure"
        )

        assert(
            model.dailyLogs.count == 6,
            "Historical logs should remain"
        )

        print("✅ Failed goal test passed!")
    }

    // MARK: - New Goal Test

    // Check that a new goal resets progress.
    static func testNewGoal() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let yesterday = calendar.date(
            byAdding: .day,
            value: -1,
            to: today
        )!

        let model = LearningViewModel(
            loadSavedData: false
        )

        // Create the previous goal.
        model.currentGoal = LearningGoal(
            title: "Old Goal",
            duration: .Week,
            startDate: yesterday
        )

        // Save yesterday's activity.
        model.dailyLogs[yesterday] = .learned
        model.currentGoalLogs[yesterday] = .learned

        // Save today's activity.
        model.dailyLogs[today] = .frozen
        model.currentGoalLogs[today] = .frozen

        model.streak = 1
        model.lastLogDate = Date()

        // Start a new goal.
        model.startNewGoal(
            title: "New Learning Goal",
            duration: .Month
        )

        // Check streak reset.
        assert(
            model.streak == 0,
            "New goal must reset streak"
        )

        // Check freeze reset.
        assert(
            model.frozenDays == 0,
            "New goal must reset freezes"
        )

        // Remove only today's old log.
        assert(
            model.dailyLogs[today] == nil,
            "Today's old log must be removed"
        )

        // Keep yesterday's history.
        assert(
            model.dailyLogs[yesterday] == .learned,
            "Previous days must remain in calendar"
        )

        // Start with empty goal logs.
        assert(
            model.currentGoalLogs.isEmpty,
            "New goal logs must start empty"
        )

        // Check the new goal details.
        assert(
            model.currentGoal?.title == "New Learning Goal",
            "New goal title is incorrect"
        )

        assert(
            model.currentGoal?.duration == .Month,
            "New goal duration is incorrect"
        )

        // Reset the 32-hour countdown.
        assert(
            model.lastLogDate == nil,
            "Countdown must reset for the new goal"
        )

        print("✅ New Goal test passed!")
    }

    // MARK: - Completed Goal Test

    // Check a goal with all days logged.
    static func testCompletedGoal() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())

        let model = LearningViewModel(
            loadSavedData: false
        )

        model.currentGoal = LearningGoal(
            title: "Test Goal",
            duration: .Week,
            startDate: start
        )

        // Log all seven days.
        for day in 0..<7 {
            let date = calendar.date(
                byAdding: .day,
                value: day,
                to: start
            )!

            model.currentGoalLogs[date] = .learned
            model.dailyLogs[date] = .learned
        }

        // Check the final deadline.
        let deadline = calendar.date(
            byAdding: .day,
            value: 7,
            to: start
        )!

        assert(
            model.goalResult(at: deadline) == .completed,
            "Goal should be completed at midnight"
        )

        // Streak becomes zero after completion.
        assert(
            model.currentStreak(at: deadline) == 0,
            "Streak should display zero after completion"
        )

        // Keep historical logs.
        assert(
            model.dailyLogs.count == 7,
            "Historical logs must remain saved"
        )

        print("✅ Completed goal test passed!")
    }
}

#endif
