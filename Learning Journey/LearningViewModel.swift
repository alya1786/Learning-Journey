
import Foundation
import Observation

@Observable
class LearningViewModel {

    // MARK: - Learning Goal

    var learningTitle = ""
    var selectedDuration: GoalDuration = .Week
    var currentGoal: LearningGoal?

    // Historical logs for the calendar
    var dailyLogs: [Date: DayStatus] = [:]

    // Logs belonging to the current goal
    var currentGoalLogs: [Date: DayStatus] = [:]

    var logTimestamps: [Date: Date] = [:]
    var lastLogDate: Date?
    var streak: Int = 0

    private let streakDuration: TimeInterval = 32 * 60 * 60

    // Disable persistence when running isolated tests
    @ObservationIgnored
    private let usesPersistence: Bool

    private func hasStreakExpired(
        at date: Date = Date()
    ) -> Bool {
        guard let lastLogDate else {
            return false
        }

        return date.timeIntervalSince(lastLogDate)
            >= streakDuration
    }

    var canStart: Bool {
        !learningTitle
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    // MARK: - Initialization

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

    // MARK: - Persistence

    private func saveProgress() {
        guard usesPersistence,
              let currentGoal else { return }

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

    var learnedDays: Int {
        currentGoalLogs.values.filter {
            $0 == .learned
        }.count
    }

    var frozenDays: Int {
        currentGoalLogs.values.filter {
            $0 == .frozen
        }.count
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

    // MARK: - Daily Status

    var todayStatus: DayStatus {
        let today = Calendar.current.startOfDay(
            for: Date()
        )

        return currentGoalLogs[today] ?? .notLogged
    }

    var canFreeze: Bool {
        isGoalActive &&
        todayStatus == .notLogged &&
        freezesRemaining > 0
    }

    // MARK: - Start Learning

    func startLearning() {
        let cleanTitle = learningTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTitle.isEmpty else { return }

        prepareForNewGoal()

        currentGoal = LearningGoal(
            title: cleanTitle,
            duration: selectedDuration
        )

        saveProgress()
    }

    // MARK: - Daily Logging

    func logToday(
        as status: DayStatus,
        at now: Date = Date()
    ) {
        guard isGoalActive(at: now) else { return }
        guard status != .notLogged else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        // Only one log per calendar day
        guard currentGoalLogs[today] == nil else {
            return
        }

        // Check freeze availability
        if status == .frozen {
            guard canFreeze(at: now) else { return }
        }

        // The first activity starts the 32-hour window.
        // An expired streak cannot be restarted
        // within the same goal.
        if let lastLogDate {
            let secondsPassed = now.timeIntervalSince(
                lastLogDate
            )

            guard secondsPassed >= 0,
                  secondsPassed < streakDuration else {
                return
            }
        } else {
            streak = 0
        }

        // Learned increases the streak.
        // Freeze preserves the streak.
        if status == .learned {
            streak += 1
        }

        // Save the daily activity
        currentGoalLogs[today] = status
        dailyLogs[today] = status

        // Both Learned and Freeze renew the 32-hour window
        logTimestamps[today] = now
        lastLogDate = now

        saveProgress()
    }

    // MARK: - Goal Updates

    private func prepareForNewGoal() {
        let today = Calendar.current.startOfDay(
            for: Date()
        )

        // Remove only today's previous log.
        // Keep earlier historical calendar entries.
        dailyLogs.removeValue(forKey: today)
        logTimestamps.removeValue(forKey: today)

        currentGoalLogs = [:]
        streak = 0
        lastLogDate = nil
    }

    func updateGoal(
        title: String,
        duration: GoalDuration
    ) {
        let cleanTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTitle.isEmpty else { return }

        if let currentGoal,
           currentGoal.title == cleanTitle,
           currentGoal.duration == duration {
            return
        }

        prepareForNewGoal()

        currentGoal = LearningGoal(
            title: cleanTitle,
            duration: duration
        )

        learningTitle = cleanTitle
        selectedDuration = duration

        saveProgress()
    }

    func startNewGoal(
        title: String,
        duration: GoalDuration
    ) {
        let cleanTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTitle.isEmpty else { return }

        prepareForNewGoal()

        learningTitle = cleanTitle
        selectedDuration = duration

        currentGoal = LearningGoal(
            title: cleanTitle,
            duration: duration,
            startDate: Date()
        )

        saveProgress()
    }

    // MARK: - Streak
    func refreshStreak(at date: Date = Date()) {
        guard lastLogDate != nil else {
            streak = 0
            return
        }

        if hasStreakExpired(at: date) {
            if streak != 0 {
                streak = 0
                saveProgress()
            }
        }
    }
    
    func currentStreak(at date: Date = Date()) -> Int {
        guard currentGoal != nil,
              let lastLogDate else {
            return 0
        }

        let timePassed = date.timeIntervalSince(
            lastLogDate
        )

        // Valid only before the 32-hour deadline
        guard timePassed >= 0,
              timePassed < streakDuration else {
            return 0
        }

        return streak
    }

    // MARK: - Goal Result

    enum GoalResult {
        case inProgress
        case completed
        case notMet
    }

    func goalResult(
        at date: Date = Date()
    ) -> GoalResult {
        guard let goal = currentGoal else {
            return .inProgress
        }

        let calendar = Calendar.current

        let start = calendar.startOfDay(
            for: goal.startDate
        )

        let end = calendar.startOfDay(
            for: goal.endDate
        )

        let today = calendar.startOfDay(
            for: date
        )

        let requiredDays = calendar.dateComponents(
            [.day],
            from: start,
            to: end
        ).day ?? 0

        let completedDays = currentGoalLogs.filter {
            day, status in

            let loggedDay = calendar.startOfDay(
                for: day
            )

            return status != .notLogged &&
                   loggedDay >= start &&
                   loggedDay < end
        }.count

        // Once the deadline has passed,
        // calculate the final result first.
        // A completed goal must stay completed.
        if today >= end {
            return completedDays >= requiredDays
                ? .completed
                : .notMet
        }

        // Fail immediately if the streak expires
        if hasStreakExpired(at: date) {
            return .notMet
        }

        return .inProgress
    }

    // MARK: - Goal Deadline

    private func isGoalActive(
        at date: Date
    ) -> Bool {
        guard let goal = currentGoal else {
            return false
        }

        // Stop the goal if the streak expires
        guard !hasStreakExpired(at: date) else {
            return false
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        let endDay = calendar.startOfDay(
            for: goal.endDate
        )

        return today >= calendar.startOfDay(
            for: goal.startDate
        ) && today < endDay
    }

    var isGoalActive: Bool {
        isGoalActive(at: Date())
    }

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

    // Kept for compatibility with existing views
    var extendedEndDate: Date? {
        currentGoal?.endDate
    }
}
