
import SwiftUI

// MARK: - Goal Result View

struct GoalResultView: View {

    // Goal result.
    let result: LearningViewModel.GoalResult

    // Start a new goal.
    let onSetGoal: () -> Void

    // Check if the goal was completed.
    private var isCompleted: Bool {
        result == .completed
    }

    // MARK: - Main View

    var body: some View {

        VStack(spacing: 0) {

            Spacer()

            // MARK: - Result Message

            VStack(spacing: 12) {

                // Result icon.
                Image(
                    systemName: isCompleted
                        ? "hands.clap.fill"
                        : "xmark.seal"
                )
                .font(.system(size: 44))
                .foregroundStyle(.orange)
                .padding(.bottom, 16)

                // Result title.
                Text(
                    isCompleted
                        ? "Well done!"
                        : "You didn't reach your goal this time."
                )
                .font(
                    .system(
                        size: 16,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

                // Next goal message.
                Text(
                    isCompleted
                        ? "Ready for your next goal?"
                        : "Want to set another goal?"
                )
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            }

            Spacer()

            // MARK: - New Goal Button

            // Open the new goal screen.
            Button(action: onSetGoal) {

                Label(
                    "Set a goal",
                    systemImage: "pencil.circle"
                )
                .font(.system(size: 17))
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(
                    .orange,
                    in: Capsule()
                )
            }
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview("Completed") {
    GoalResultView(
        result: .completed,
        onSetGoal: {}
    )
 .background(.black)
  .preferredColorScheme(.dark)
}

#Preview("Not Completed") {
    GoalResultView(
        result: .notMet,
        onSetGoal: {}
    )
    .background(.black)
    .preferredColorScheme(.dark)
}
