
import SwiftUI

struct DailyActionButtons: View {

    let status: DayStatus
    let canFreeze: Bool
    let freezesUsed: Int
    let freezeLimit: Int
    let onLearned: () -> Void
    let onFreeze: () -> Void

    private var isLogged: Bool {
        status != .notLogged
    }

    private var canUseFreeze: Bool {
        !isLogged && canFreeze
    }

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

    var body: some View {

        VStack(spacing: 0) {

            Button(action: onLearned) {

                Text(
                    status == .learned
                    ? "Logged as Learned"
                    : "Log as Learned"
                )
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(
                    isLogged ? Color(white: 0.38) : .white
                )
                .frame(width: 272, height: 272)
                .glassEffect(
                    .regular.tint(
                        isLogged ? .clear : learnedColor
                    ),
                    in: Circle()
                )
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(isLogged)

            Spacer()
                .frame(height: 48)

            Button(action: onFreeze) {

                Text(
                    status == .frozen || freezesUsed >= freezeLimit
                        ? "Freezed for a day"
                        : "Freeze for a day"
                )
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    canUseFreeze ? .white : Color(white: 0.38)
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

            Text(
                "\(freezesUsed) out of \(freezeLimit) Freezes used"
            )
            .font(.system(size: 13))
            .foregroundStyle(.gray)
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
    }
}
