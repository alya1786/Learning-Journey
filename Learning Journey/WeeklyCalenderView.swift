//
//  WeeklyCalenderView.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//

import Foundation
import SwiftUI

struct WeeklyCalendarView: View {
    let dailyLogs: [Date: DayStatus]
    
    private let calendar = Calendar.current
    private let today = Date()
    
    
    private func dayColor(for date: Date) -> Color {
        let day = calendar.startOfDay(for: date)
        let isToday = calendar.isDateInToday(date)

        switch dailyLogs[day] ?? .notLogged {
        case .learned:
            return Color.orange.opacity(isToday ? 1 : 0.18)

        case .frozen:
            return Color.cyan.opacity(isToday ? 1 : 0.18)

        case .notLogged:
            return .clear
        }
    }


    
    private func numberColor(for date: Date) -> Color {
        let day = calendar.startOfDay(for: date)
        let isToday = calendar.isDateInToday(date)

        switch dailyLogs[day] ?? .notLogged {
        case .learned:
            return isToday ? .white : .orange

        case .frozen:
            return isToday ? .white : .cyan

        case .notLogged:
            return .white
        }
    }

    private var weekDates: [Date] {
        let weekday = calendar.component(.weekday, from: today)

        guard let sunday = calendar.date(
            byAdding: .day,
            value: -(weekday - 1),
            to: calendar.startOfDay(for: today)
        ) else {
            return []
        }

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: sunday)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDates, id: \.self) { date in
                
                VStack(spacing: 12) {
                    Text(date.formatted(.dateTime.weekday(.narrow)))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white)

                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(numberColor(for: date))
                        .frame(width: 43, height: 43)
                        .background {
                            Circle()
                                .fill(dayColor(for: date))
                        }
                                        }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    WeeklyCalendarView(dailyLogs: [:])
        .padding()
        .background(.black)
        .preferredColorScheme(.dark)
}
