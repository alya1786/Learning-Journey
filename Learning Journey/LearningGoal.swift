//
//  LearningGoal.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//

import Foundation
import SwiftUI


enum GoalDuration: String, CaseIterable, Codable {
    case Week
    case Month
    case Year
    
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
struct LearningGoal: Codable {
    let title: String
    let duration: GoalDuration
    var startDate: Date = Date()

    var endDate: Date {
        let calendar = Calendar.current

        switch duration {
        case .Week:
            return calendar.date(
                byAdding: .day,
                value: 7,
                to: startDate
            ) ?? startDate

        case .Month:
            return calendar.date(
                byAdding: .month,
                value: 1,
                to: startDate
            ) ?? startDate

        case .Year:
            return calendar.date(
                byAdding: .year,
                value: 1,
                to: startDate
            ) ?? startDate
        }
    }

    enum CodingKeys: String, CodingKey {
        case title
        case duration
        case startDate
    }

    init(
        title: String,
        duration: GoalDuration,
        startDate: Date = Date()
    ) {
        self.title = title
        self.duration = duration
        self.startDate = startDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        title = try container.decode(
            String.self,
            forKey: .title
        )

        duration = try container.decode(
            GoalDuration.self,
            forKey: .duration
        )

        startDate = try container.decodeIfPresent(
            Date.self,
            forKey: .startDate
        ) ?? Date()
    }
}
