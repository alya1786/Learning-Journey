
//
//  DayStatus.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//

import Foundation

// MARK: - Day Status

// Activity status for each day.
enum DayStatus: String, Codable {

    // No activity recorded.
    case notLogged

    // Learning completed.
    case learned

    // Freeze used.
    case frozen
}
