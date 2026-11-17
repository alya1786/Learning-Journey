
import Foundation

// MARK: - Saved Learning Data

// Data saved by the app.
struct SavedLearningData: Codable {

    // Current learning goal.
    var goal: LearningGoal

    // All activity history.
    var dailyLogs: [Date: DayStatus]

    // Current goal activity.
    var currentGoalLogs: [Date: DayStatus]

    // Current streak.
    var streak: Int

    // Last activity time.
    var lastLogDate: Date?

    // Activity timestamps.
    var logTimestamps: [Date: Date]

    // MARK: - Coding Keys

    // Keys used to save data.
    enum CodingKeys: String, CodingKey {
        case goal
        case dailyLogs
        case currentGoalLogs
        case streak
        case lastLogDate
        case logTimestamps
    }

    // MARK: - Initialization

    // Create saved data.
    init(
        goal: LearningGoal,
        dailyLogs: [Date: DayStatus],
        currentGoalLogs: [Date: DayStatus],
        streak: Int,
        lastLogDate: Date?,
        logTimestamps: [Date: Date] = [:]
    ) {
        self.goal = goal
        self.dailyLogs = dailyLogs
        self.currentGoalLogs = currentGoalLogs
        self.streak = streak
        self.lastLogDate = lastLogDate
        self.logTimestamps = logTimestamps
    }

    // MARK: - Load Saved Data

    // Decode saved data.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        // Load the goal.
        goal = try container.decode(
            LearningGoal.self,
            forKey: .goal
        )

        // Load activity history.
        dailyLogs = try container.decode(
            [Date: DayStatus].self,
            forKey: .dailyLogs
        )

        // Load the streak.
        streak = try container.decode(
            Int.self,
            forKey: .streak
        )

        // Load the last activity time.
        lastLogDate = try container.decodeIfPresent(
            Date.self,
            forKey: .lastLogDate
        )

        // Load activity timestamps.
        logTimestamps = try container.decodeIfPresent(
            [Date: Date].self,
            forKey: .logTimestamps
        ) ?? [:]

        // Load current goal activity.
        if let savedGoalLogs = try container.decodeIfPresent(
            [Date: DayStatus].self,
            forKey: .currentGoalLogs
        ) {
            currentGoalLogs = savedGoalLogs
        } else {

            // MARK: - Old Data Support

            // Restore goal logs from old data.
            let calendar = Calendar.current

            let start = calendar.startOfDay(
                for: goal.startDate
            )

            let end = calendar.startOfDay(
                for: goal.endDate
            )

            // Keep only days within this goal.
            currentGoalLogs = dailyLogs.filter {
                date, status in

                let day = calendar.startOfDay(
                    for: date
                )

                return day >= start &&
                       day < end &&
                       status != .notLogged
            }
        }
    }
}

// MARK: - Learning Storage

// Save and load app data.
enum LearningStorage {

    // Storage key.
    private static let key = "savedLearningData"

    // MARK: - Save

    // Save progress to the device.
    static func save(_ data: SavedLearningData) {
        do {
            let encoded = try JSONEncoder().encode(data)

            UserDefaults.standard.set(
                encoded,
                forKey: key
            )
        } catch {
            print("Failed to save learning data:", error)
        }
    }

    // MARK: - Load

    // Load progress from the device.
    static func load() -> SavedLearningData? {

        // Check for saved data.
        guard let data = UserDefaults.standard.data(
            forKey: key
        ) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(
                SavedLearningData.self,
                from: data
            )
        } catch {
            print("Failed to load learning data:", error)
            return nil
        }
    }

    // MARK: - Clear

    // Remove saved progress.
    static func clear() {
        UserDefaults.standard.removeObject(
            forKey: key
        )
    }
}
