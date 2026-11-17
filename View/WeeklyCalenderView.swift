
import SwiftUI

// MARK: - Weekly Calendar View

struct WeeklyCalendarView: View {

    // Saved daily activities.
    let dailyLogs: [Date: DayStatus]

    // Current date provided by ActivityView.
    let currentDate: Date

    // Calendar settings.
    private let calendar = Calendar.current

    // MARK: - Day Colors

    // Get the circle color.
    private func dayColor(
        for date: Date,
        today: Date
    ) -> Color {

        let day = calendar.startOfDay(for: date)
        let isToday = calendar.isDate(date, inSameDayAs: today)

        switch dailyLogs[day] ?? .notLogged {

        case .learned:
            return .orange.opacity(0.18)

        case .frozen:
            return .cyan.opacity(0.18)

        case .notLogged:
            return isToday ? .orange : .clear
        }
    }

    // Get the day number color.
    private func numberColor(
        for date: Date,
        today: Date
    ) -> Color {

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

    // MARK: - Week Dates

    // Get the current week's dates.
    private func weekDates(
        for today: Date
    ) -> [Date] {

        let weekday = calendar.component(
            .weekday,
            from: today
        )

        // Start the week on Sunday.
        guard let sunday = calendar.date(
            byAdding: .day,
            value: -(weekday - 1),
            to: calendar.startOfDay(for: today)
        ) else {
            return []
        }

        // Return seven days.
        return (0..<7).compactMap { offset in
            calendar.date(
                byAdding: .day,
                value: offset,
                to: sunday
            )
        }
    }

    // MARK: - Main View

    var body: some View {

        HStack(spacing: 0) {

            // Show each day of the week.
            ForEach(
                weekDates(for: currentDate),
                id: \.self
            ) { date in

                VStack(spacing: 12) {

                    // Weekday letter.
                    Text(
                        date.formatted(
                            .dateTime.weekday(.narrow)
                        )
                    )
                    .font(
                        .system(
                            size: 12,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.white)

                    // Day number.
                    Text(
                        "\(calendar.component(.day, from: date))"
                    )
                    .font(
                        .system(
                            size: 20,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        numberColor(
                            for: date,
                            today: currentDate
                        )
                    )
                    .frame(width: 43, height: 43)

                    // Activity circle.
                    .background {
                        Circle()
                            .fill(
                                dayColor(
                                    for: date,
                                    today: currentDate
                                )
                            )
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    WeeklyCalendarView(
        dailyLogs: [:],
        currentDate: Date()
    )
    .padding()
    .background(.black)
   .preferredColorScheme(.dark)
}
