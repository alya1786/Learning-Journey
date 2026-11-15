
import SwiftUI

// MARK: - Activities View

struct ActivitiesView: View {

    // Saved daily activities.
    let dailyLogs: [Date: DayStatus]

    // Close the screen.
    @Environment(\.dismiss) private var dismiss

    // Calendar settings.
    private let calendar = Calendar.current

    // MARK: - Months

    // Get the next 12 months.
    private var months: [Date] {

        guard let currentMonth = calendar.dateInterval(
            of: .month,
            for: Date()
        )?.start else {
            return []
        }

        return (0..<12).compactMap { offset in
            calendar.date(
                byAdding: .month,
                value: offset,
                to: currentMonth
            )
        }
    }

    // MARK: - Main View

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - Header

            HStack {

                // Back button.
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(
                            .system(
                                size: 18,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .glassEffect(
                            .regular,
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)

                Spacer()

                // Screen title.
                Text("Activities")
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.white)

                Spacer()

                // Keep the title centered.
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)

            // MARK: - Monthly Calendars

            ScrollView {

                LazyVStack(spacing: 18) {

                    // Show each month.
                    ForEach(months, id: \.self) { month in

                        CalendarView(
                            month: month,
                            dailyLogs: dailyLogs
                        )

                        // Separate the months.
                        Divider()
                            .overlay(
                                Color.gray.opacity(0.3)
                            )
                    }
                }
                .padding(.horizontal, 16)
            }
        }

        // MARK: - Appearance

        // Keep the background black.
        .background(
            Color.black.ignoresSafeArea()
        )

        // Always use dark mode.
        .preferredColorScheme(.dark)

        // Hide the default navigation bar.
        .toolbar(
            .hidden,
            for: .navigationBar
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ActivitiesView(
            dailyLogs: [:]
        )
        .preferredColorScheme(.dark)
    }
}
