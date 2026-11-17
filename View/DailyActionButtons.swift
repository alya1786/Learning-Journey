
import SwiftUI


// MARK: - Daily Action Buttons

struct DailyActionButtons: View {

    // Today's activity.
    let status: DayStatus

    // Freeze availability.
    let canFreeze: Bool
    let freezesUsed: Int
    let freezeLimit: Int

    // Button actions.
    let onLearned: () -> Void
    let onFreeze: () -> Void

    // Check if today is logged.
    private var isLogged: Bool {
        status != .notLogged
    }

    // Check if Freeze can be used.
    private var canUseFreeze: Bool {
        !isLogged && canFreeze
    }

    // Button colors.
    private let learnedColor = Color(
        red: 1,
        green: 0.54,
        blue: 0.13
    )

    private let freezeColor = Color(
        red: 0.17,
        green: 0.78,
        blue: 0.94
    )

    // MARK: - Main View

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - Learned Button

            // Log today's learning.
            Button(action: onLearned) {

                Text(
                    status == .learned
                        ? "Logged as Learned"
                        : "Log as Learned"
                )
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(
                    isLogged ? Color(white: 0.60) : .white
                )
                .frame(width: 272, height: 272)
                .glassEffect(
                    .regular.tint(
                        isLogged ? .clear : learnedColor
                    ),
                    in: Circle()
                    
                ).contentShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(isLogged)

            Spacer()
                .frame(height: 48)

            // MARK: - Freeze Button

            // Freeze today's activity.
            Button(action: onFreeze) {

                Text(
                    status == .frozen
                        ? "Frozen for a day"
                        : "Freeze for a day"
                )
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    canUseFreeze ? .white : Color(white: 0.60)
                )
                .frame(width: 272, height: 46)
                .glassEffect(
                    .regular.tint(
                        canUseFreeze ? freezeColor : .clear
                    ),
                    in: Capsule()
                )
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!canUseFreeze)

            // MARK: - Freeze Counter

            // Show used freezes.
            Text(
                "\(freezesUsed) out of \(freezeLimit) Freezes used"
            )
            .font(.system(size: 13))
            .foregroundStyle(.gray)
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.success, trigger: status)
    }
}
