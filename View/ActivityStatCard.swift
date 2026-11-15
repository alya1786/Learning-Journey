
import SwiftUI

// MARK: - Activity Stat Card

// Reusable activity card.
struct ActivityStatCard: View {

    // Card information.
    let icon: String
    let count: Int
    let title: String
    let color: Color

    // Card shape.
    private let cardShape = RoundedRectangle(
        cornerRadius: 34,
        style: .continuous
    )

    // Dark card background.
    private let cardColor = Color(
        red: 16.0 / 255,
        green: 16.0 / 255,
        blue: 16.0 / 255
    )

    // MARK: - Main View

    var body: some View {

        VStack(spacing: 6) {

            // Activity icon.
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)

           
            // Number of days.
            Text("\(count) \(count == 1 ? "day" : "days")")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .contentTransition(.numericText(value: Double(count)))
                .animation(.snappy, value: count)

            // Activity title.
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)

        // Card background.
        .background {
            cardShape
                .fill(cardColor)
        }

        // Glass effect.
        .glassEffect(
            .regular.tint(.clear),
            in: cardShape
        )

        // Card border.
        .overlay {
            cardShape
                .strokeBorder(
                    Color.white.opacity(0.12),
                    lineWidth: 0.5
                )
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {

        // Learned card.
        ActivityStatCard(
            icon: "flame.fill",
            count: 0,
            title: "Learned",
            color: .orange
        )

        // Freeze card.
        ActivityStatCard(
            icon: "snowflake",
            count: 0,
            title: "Freezed",
            color: .cyan
        )
    }
    .padding()
    .background(.black)
    .preferredColorScheme(.dark)
}
