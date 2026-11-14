
import Foundation

struct SavedLearningData: Codable {

    var goal: LearningGoal

    // All historical activity
    var dailyLogs: [Date: DayStatus]

    // Activity belonging to the current goal only
    var currentGoalLogs: [Date: DayStatus]

    var streak: Int
    var lastLogDate: Date?
    var logTimestamps: [Date: Date]

    enum CodingKeys: String, CodingKey {
        case goal
        case dailyLogs
        case currentGoalLogs
        case streak
        case lastLogDate
        case logTimestamps
    }

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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        goal = try container.decode(
            LearningGoal.self,
            forKey: .goal
        )

        dailyLogs = try container.decode(
            [Date: DayStatus].self,
            forKey: .dailyLogs
        )

        streak = try container.decode(
            Int.self,
            forKey: .streak
        )

        lastLogDate = try container.decodeIfPresent(
            Date.self,
            forKey: .lastLogDate
        )

        logTimestamps = try container.decodeIfPresent(
            [Date: Date].self,
            forKey: .logTimestamps
        ) ?? [:]

        if let savedGoalLogs = try container.decodeIfPresent(
            [Date: DayStatus].self,
            forKey: .currentGoalLogs
        ) {
            currentGoalLogs = savedGoalLogs
        } else {
            // Migration from the previous storage format
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: goal.startDate)
            let end = calendar.startOfDay(for: goal.endDate)

            currentGoalLogs = dailyLogs.filter { date, status in
                let day = calendar.startOfDay(for: date)

                return day >= start &&
                       day < end &&
                       status != .notLogged
            }
        }
    }
}

enum LearningStorage {

    private static let key = "savedLearningData"

    static func save(_ data: SavedLearningData) {
        do {
            let encoded = try JSONEncoder().encode(data)
            UserDefaults.standard.set(encoded, forKey: key)
        } catch {
            print("Failed to save learning data:", error)
        }
    }

    static func load() -> SavedLearningData? {
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

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
