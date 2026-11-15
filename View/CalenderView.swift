
import SwiftUI

// MARK: - Calendar View

struct CalendarView: View {

    // Selected month and saved activities.
    let month: Date
    let dailyLogs: [Date: DayStatus]

    // Calendar settings.
    private let calendar = Calendar.current

    // Seven columns for the week.
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: 7
    )

    // MARK: - Month Dates

    // Get all dates in the selected month.
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

        // Find the first weekday.
        let firstWeekday = calendar.component(
            .weekday,
            from: interval.start
        )

        // Add empty days before the first date.
        let emptyDays = (firstWeekday - 1) % 7

        // Create the month's dates.
        let dates = (0..<numberOfDays).compactMap {
            calendar.date(
                byAdding: .day,
                value: $0,
                to: interval.start
            )
        }

        return Array<Date?>(
            repeating: nil,
            count: emptyDays
        ) + dates.map { Optional($0) }
    }

    // MARK: - Day Colors

  
   
    // Get the day number color.
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

    // Get the circle color.
    private func dayColor(for date: Date) -> Color {

        let day = calendar.startOfDay(for: date)
        let isToday = calendar.isDateInToday(date)

        switch dailyLogs[day] ?? .notLogged {

        case .learned:
            return .orange.opacity(0.18)

        case .frozen:
            return .cyan.opacity(0.18)

        case .notLogged:
            return isToday ? .orange : .clear
        }
    }


    // MARK: - Main View

    var body: some View {

        VStack(alignment: .leading, spacing: 18) {

            // Show the month and year.
            Text(
                month.formatted(
                    .dateTime.month(.wide).year()
                )
            )
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(.white)

            // Show the monthly calendar.
            LazyVGrid(columns: columns, spacing: 12) {

                // Weekday names.
                ForEach(
                    [
                        "SUN", "MON", "TUE",
                        "WED", "THU", "FRI", "SAT"
                    ],
                    id: \.self
                ) { day in

                    Text(day)
                        .font(
                            .system(
                                size: 12,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                }

                // Month dates.
                ForEach(
                    daysInMonth.indices,
                    id: \.self
                ) { index in

                    if let date = daysInMonth[index] {

                        Text(
                            "\(calendar.component(.day, from: date))"
                        )
                        .font(
                            .system(
                                size: 18,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            numberColor(for: date)
                        )
                        .frame(width: 42, height: 42)
                        .background {

                            // Activity circle.
                            Circle()
                                .fill(
                                    dayColor(for: date)
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}
