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

        print("✅ All Goal Result tests passed!")
    }
}

#endif
