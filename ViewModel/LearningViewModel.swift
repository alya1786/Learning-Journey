
import Foundation
import Observation

@Observable
class LearningViewModel {

    // MARK: - Learning Goal

    // Goal information.
    var learningTitle = ""
    var selectedDuration: GoalDuration = .Week
    var currentGoal: LearningGoal?

    // All calendar history.
    var dailyLogs: [Date: DayStatus] = [:]

    // Current goal activity.
    var currentGoalLogs: [Date: DayStatus] = [:]

    // Activity times.
    var logTimestamps: [Date: Date] = [:]

    // Last activity time.
    var lastLogDate: Date?

    // Current streak.
    var streak: Int = 0

    // Streak expires after 32 hours.
    private let streakDuration: TimeInterval = 32 * 60 * 60

    // Disable saving during tests.
    @ObservationIgnored
    private let usesPersistence: Bool

    // Check if 32 hours have passed.
    private func hasStreakExpired(
        at date: Date = Date()
    ) -> Bool {
        guard let lastLogDate else {
            return false
        }

        return date.timeIntervalSince(lastLogDate)
            >= streakDuration
    }

    // Enable Start when a title exists.
    var canStart: Bool {
        !learningTitle
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    // MARK: - Initialization

    // Load saved progress.
    init(loadSavedData: Bool = true) {
        usesPersistence = loadSavedData

        if loadSavedData,
           let saved = LearningStorage.load() {

            currentGoal = saved.goal
            learningTitle = saved.goal.title
            selectedDuration = saved.goal.duration

            dailyLogs = saved.dailyLogs
            currentGoalLogs = saved.currentGoalLogs
            logTimestamps = saved.logTimestamps

            streak = saved.streak
            lastLogDate = saved.lastLogDate
        }

        if loadSavedData {
            refreshStreak()
        }
    }

    // MARK: - Saving Data

    // Save current progress.
    private func saveProgress() {
        guard usesPersistence,
              let currentGoal else {
            return
        }

        let data = SavedLearningData(
            goal: currentGoal,
            dailyLogs: dailyLogs,
            currentGoalLogs: currentGoalLogs,
            streak: streak,
            lastLogDate: lastLogDate,
            logTimestamps: logTimestamps
        )

        LearningStorage.save(data)
    }

    // MARK: - Activity Counts

    // Count learned days.
    var learnedDays: Int {
        currentGoalLogs.values.filter {
            $0 == .learned
        }.count
    }

    // Count frozen days.
    var frozenDays: Int {
        currentGoalLogs.values.filter {
            $0 == .frozen
        }.count
    }

    // Freeze limit for each duration.
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

    // Available freezes.
    var freezesRemaining: Int {
        max(0, freezeLimit - frozenDays)
    }

    // MARK: - Daily Status

    // Today's activity.
    var todayStatus: DayStatus {
        let today = Calendar.current.startOfDay(
            for: Date()
        )

        return currentGoalLogs[today] ?? .notLogged
    }

    // Enable the Freeze button.
    var canFreeze: Bool {
        isGoalActive &&
        todayStatus == .notLogged &&
        freezesRemaining > 0
    }

    // MARK: - Start Learning

    // Start the first goal.
    func startLearning() {
        let cleanTitle = learningTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTitle.isEmpty else {
            return
        }

        prepareForNewGoal()

        currentGoal = LearningGoal(
            title: cleanTitle,
            duration: selectedDuration
        )

        saveProgress()
    }

    // MARK: - Daily Logging

    // Record Learned or Freeze.
    func logToday(
        as status: DayStatus,
        at now: Date = Date()
    ) {
        // Allow logging only during an active goal.
        guard isGoalActive(at: now) else {
            return
        }

        // Ignore empty status.
        guard status != .notLogged else {
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        // Allow one activity per day.
        guard currentGoalLogs[today] == nil else {
            return
        }

        // Check remaining freezes.
        if status == .frozen {
            guard canFreeze(at: now) else {
                return
            }
        }

        // Check the 32-hour deadline.
        if let lastLogDate {
            let secondsPassed = now.timeIntervalSince(
                lastLogDate
            )

            guard secondsPassed >= 0,
                  secondsPassed < streakDuration else {
                return
            }
        } else {
            // First activity starts the streak.
            streak = 0
        }

        // Learned increases the streak.
        if status == .learned {
            streak += 1
        }

        // Save today's status.
        currentGoalLogs[today] = status
        dailyLogs[today] = status

        // Both actions renew the 32-hour timer.
        logTimestamps[today] = now
        lastLogDate = now

        saveProgress()
    }

    // MARK: - Goal Updates

    // Reset progress for a new goal.
    private func prepareForNewGoal() {
        let today = Calendar.current.startOfDay(
            for: Date()
        )

        // Remove today's previous activity.
        dailyLogs.removeValue(forKey: today)
        logTimestamps.removeValue(forKey: today)

        // Keep older calendar history.
        currentGoalLogs = [:]

        // Reset the streak and timer.
        streak = 0
        lastLogDate = nil
    }

    // Update the current goal.
    func updateGoal(
        title: String,
        duration: GoalDuration
    ) {
        let cleanTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTitle.isEmpty else {
            return
        }

        // Do nothing if nothing changed.
        if let currentGoal,
           currentGoal.title == cleanTitle,
           currentGoal.duration == duration {
            return
        }

        prepareForNewGoal()

        // Save the updated goal.
        currentGoal = LearningGoal(
            title: cleanTitle,
            duration: duration
        )

        learningTitle = cleanTitle
        selectedDuration = duration

        saveProgress()
    }

    // Start another goal.
    func startNewGoal(
        title: String,
        duration: GoalDuration
    ) {
        let cleanTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTitle.isEmpty else {
            return
        }

        prepareForNewGoal()

        learningTitle = cleanTitle
        selectedDuration = duration

        // Create a goal starting now.
        currentGoal = LearningGoal(
            title: cleanTitle,
            duration: duration,
            startDate: Date()
        )

        saveProgress()
    }

    // MARK: - Streak

    // Refresh the streak.
    func refreshStreak(at date: Date = Date()) {

        // Reset the streak after a final result.
        if goalResult(at: date) != .inProgress {
            if streak != 0 {
                streak = 0
                saveProgress()
            }

            return
        }

        // No activity means no streak.
        guard lastLogDate != nil else {
            streak = 0
            return
        }

        // Reset after 32 hours.
        if hasStreakExpired(at: date) {
            if streak != 0 {
                streak = 0
                saveProgress()
            }
        }
    }

    // Get the active streak.
    func currentStreak(at date: Date = Date()) -> Int {

        // Finished goals have no active streak.
        guard goalResult(at: date) == .inProgress,
              let lastLogDate else {
            return 0
        }

        let timePassed = date.timeIntervalSince(
            lastLogDate
        )

        // Check the 32-hour window.
        guard timePassed >= 0,
              timePassed < streakDuration else {
            return 0
        }

        return streak
    }

    // MARK: - Goal Result

    // Possible goal results.
    enum GoalResult {
        case inProgress
        case completed
        case notMet
    }

    // Check the goal result.
    func goalResult(
        at date: Date = Date()
    ) -> GoalResult {

        // No goal has started.
        guard let goal = currentGoal else {
            return .inProgress
        }

        let calendar = Calendar.current

        // First calendar day.
        let start = calendar.startOfDay(
            for: goal.startDate
        )

        // Midnight after the final goal day.
        let end = calendar.startOfDay(
            for: goal.endDate
        )

        // Current calendar day.
        let today = calendar.startOfDay(
            for: date
        )

        // Count the required days.
        let requiredDays = calendar.dateComponents(
            [.day],
            from: start,
            to: end
        ).day ?? 0

        // Count logged days within the goal.
        let completedDays = currentGoalLogs.filter {
            day, status in

            let loggedDay = calendar.startOfDay(
                for: day
            )

            return status != .notLogged &&
                   loggedDay >= start &&
                   loggedDay < end
        }.count

        // Check completion at the final midnight.
        if today >= end {
            return completedDays >= requiredDays
                ? .completed
                : .notMet
        }

        // Fail if 32 hours have passed.
        if hasStreakExpired(at: date) {
            return .notMet
        }

        // The goal is still active.
        return .inProgress
    }

    // MARK: - Goal Deadline

    // Check if the goal is active.
    private func isGoalActive(
        at date: Date
    ) -> Bool {

        guard let goal = currentGoal else {
            return false
        }

        // Stop after 32 hours without activity.
        guard !hasStreakExpired(at: date) else {
            return false
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)

        // Midnight after the final day.
        let endDay = calendar.startOfDay(
            for: goal.endDate
        )

        // Allow activity only within goal dates.
        return today >= calendar.startOfDay(
            for: goal.startDate
        ) && today < endDay
    }

    // Current goal availability.
    var isGoalActive: Bool {
        isGoalActive(at: Date())
    }

    // Check Freeze availability at a date.
    private func canFreeze(
        at date: Date
    ) -> Bool {
        let today = Calendar.current.startOfDay(
            for: date
        )

        return isGoalActive(at: date) &&
               currentGoalLogs[today] == nil &&
               freezesRemaining > 0
    }

    // MARK: - Goal End Date

    // Keep the end date available to other views.
    var extendedEndDate: Date? {
        currentGoal?.endDate
    }
}
