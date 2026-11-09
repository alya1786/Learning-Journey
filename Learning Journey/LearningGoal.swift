//
//  LearningGoal.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//

import Foundation
import SwiftUI


enum GoalDuration: String,CaseIterable{
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
struct LearningGoal {
    let title: String
    let duration: GoalDuration
}
