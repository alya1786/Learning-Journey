
//
//  LearningGoal.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//

import Foundation
import SwiftUI

// MARK: - Goal Duration

// Available goal durations.
enum GoalDuration: String, CaseIterable, Codable {
    case Week
    case Month
    case Year

    // Width of each duration button.
    var buttonWidth: CGFloat {
        switch self {
        case .Week:
            return 84

        case .Month:
            return 91

        case .Year:
            return 75
        }
    }
}

// MARK: - Learning Goal

// Stores the goal information.
struct LearningGoal: Codable {

    // Goal name.
    let title: String

    // Selected duration.
    let duration: GoalDuration

    // Date the goal started.
    var startDate: Date = Date()

    // MARK: - End Date

    // Calculate the goal end date.
    var endDate: Date {
        let calendar = Calendar.current

        switch duration {
        case .Week:
            // Add seven days.
            return calendar.date(
                byAdding: .day,
                value: 7,
                to: startDate
            ) ?? startDate

        case .Month:
            // Add one calendar month.
            return calendar.date(
                byAdding: .month,
                value: 1,
                to: startDate
            ) ?? startDate

        case .Year:
            // Add one calendar year.
            return calendar.date(
                byAdding: .year,
                value: 1,
                to: startDate
            ) ?? startDate
        }
    }

    // MARK: - Saved Data

    // Keys used to save the goal.
    enum CodingKeys: String, CodingKey {
        case title
        case duration
        case startDate
    }

    // MARK: - Initialization

    // Create a new goal.
    init(
        title: String,
        duration: GoalDuration,
        startDate: Date = Date()
    ) {
        self.title = title
        self.duration = duration
        self.startDate = startDate
    }

    // Load a saved goal.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        // Load the goal name.
        title = try container.decode(
            String.self,
            forKey: .title
        )

        // Load the duration.
        duration = try container.decode(
            GoalDuration.self,
            forKey: .duration
        )

        // Load the start date.
        startDate = try container.decodeIfPresent(
            Date.self,
            forKey: .startDate
        ) ?? Date()
    }
}
