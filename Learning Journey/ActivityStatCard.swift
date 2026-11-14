
import SwiftUI

struct ActivityStatCard: View {

    let icon: String
    let count: Int
    let title: String
    let color: Color

    private let cardShape = RoundedRectangle(
        cornerRadius: 34,
        style: .continuous
    )

    
    private let cardColor = Color(
        red: 16.0 / 255,
        green: 16.0 / 255,
        blue: 16.0 / 255
    )

    var body: some View {

        VStack(spacing: 6) {

            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)

            Text("\(count) \(count == 1 ? "day" : "days")")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(.white)

        }

        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background {
            cardShape
                .fill(cardColor)
        }
        .glassEffect(
            .regular.tint(.clear),
            in: cardShape
        )
        .overlay {
            cardShape
                .strokeBorder(
                    Color.white.opacity(0.12),
                    lineWidth: 0.5
                )
        }
    }
}

#Preview {
    HStack(spacing: 12) {

        ActivityStatCard(
            icon: "flame.fill",
            count: 0,
            title: "Learned",
            color: .orange
        )

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
