
import SwiftUI
import Playgrounds

// MARK: - Content View

struct ContentView: View {

    // App data.
    @State private var viewModel = LearningViewModel()

    var body: some View {
        NavigationStack {
            Group {

                // Show the current goal.
                if viewModel.currentGoal != nil {
                    ActivityView(viewModel: viewModel)

                } else {

                    // MARK: - Onboarding

                    VStack(alignment: .leading, spacing: 8) {

                        // App icon.
                        Image(systemName: "flame.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.orange)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .center
                            )
                            .padding(.top, 80)
                            .padding(.bottom, 80)

                        // Welcome title.
                        HStack(spacing: 0) {
                            Text("Hello ")
                                .fontWeight(.regular)

                            Text("Learner")
                                .bold()
                        }
                        .font(.system(size: 34))
                        .foregroundStyle(.white)

                        // App description.
                        Text("This app will help you learn everyday!")
                            .font(.system(size: 17))
                            .foregroundStyle(.gray)
                            .padding(.bottom, 32)

                        // Goal title.
                        Text("I want to learn")
                            .foregroundStyle(.white)
                            .font(.system(size: 16))

                        // Goal input.
                        TextField(
                            "Swift",
                            text: $viewModel.learningTitle
                        )
                        .textFieldStyle(.plain)

                        Divider()

                        // MARK: - Duration Selection

                        VStack(
                            alignment: .leading,
                            spacing: 20
                        ) {

                            Text("I want to learn it in a")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)

                            // Duration buttons.
                            HStack {

                                ForEach(
                                    GoalDuration.allCases,
                                    id: \.self
                                ) { duration in

                                    DurationButton(
                                        title: duration.rawValue,
                                        isSelected:
                                            viewModel.selectedDuration == duration,
                                        buttonWidth: duration.buttonWidth
                                    ) {
                                        viewModel.selectedDuration = duration
                                    }
                                }
                            }
                        }

                        Spacer()

                        // MARK: - Start Button

                        // Create a learning goal.
                        Button {
                            viewModel.startLearning()
                        } label: {
                            Text("Start Learning")
                        }
                        .font(
                            .system(
                                size: 19,
                                weight: .semibold
                            )
                        )
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .glassEffect(
                            .regular.tint(
                                viewModel.canStart ? .orange : .gray
                            ),
                            in: Capsule()
                        )
                        .frame(
                            maxWidth: .infinity,
                            alignment: .center
                        )
                        .foregroundStyle(
                            viewModel.canStart
                                ? Color.white
                                : Color.gray
                        )
                        .disabled(!viewModel.canStart)

                        // Edit reminder.
                        Text("You can edit your desire later")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .center
                            )
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
