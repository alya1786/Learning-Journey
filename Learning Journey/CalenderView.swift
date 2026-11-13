//
//  CalenderView.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//

import Foundation
import SwiftUI

struct CalendarView: View {
    
    let month: Date
    let dailyLogs: [Date: DayStatus]

    private let calendar = Calendar.current
    
    private func numberColor(for date: Date) -> Color {
        let day = calendar.startOfDay(for: date)

        switch dailyLogs[day] ?? .notLogged {
        case .learned:
            return .orange
        case .frozen:
            return .cyan
        case .notLogged:
            return .white
        }
    }
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: 7
    )

    private var daysInMonth: [Date?] {
        guard let interval = calendar.dateInterval(
            of: .month,
            for: month
        ),
        let numberOfDays = calendar.range(
            of: .day,
            in: .month,
            for: month
        )?.count else {
            return []
        }

        let firstWeekday = calendar.component(
            .weekday,
            from: interval.start
        )

        let emptyDays = (firstWeekday - 1) % 7

        let dates = (0..<numberOfDays).compactMap {
            calendar.date(
                byAdding: .day,
                value: $0,
                to: interval.start
            )
        }

        return Array<Date?>(repeating: nil, count: emptyDays)
            + dates.map { Optional($0) }
    }
    private func dayColor(for date: Date) -> Color {
        let day = calendar.startOfDay(for: date)

        switch dailyLogs[day] ?? .notLogged {
        case .learned:
            return Color.orange.opacity(0.18)
        case .frozen:
            return Color.cyan.opacity(0.18)
        case .notLogged:
            return .clear
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(month.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.white)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(
                    ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"],
                    id: \.self
                ) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                }

                ForEach(daysInMonth.indices, id: \.self) { index in
                    if let date = daysInMonth[index] {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(numberColor(for: date))
                            .frame(width: 42, height: 42)
                            .background {
                                Circle()
                                    .fill(dayColor(for: date))
                            }
                            .frame(maxWidth: .infinity)
                    }
                }
                }
            }
        }
    }

