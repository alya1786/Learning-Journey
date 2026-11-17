
import SwiftUI

// MARK: - Update Learning Goal

struct UpdateLearningGoalView: View {

    // Close the sheet.
    @Environment(\.dismiss) private var dismiss

    // App data.
    @Bindable var viewModel: LearningViewModel

    // New goal or edit mode.
    var isNewGoal: Bool

    // Form values.
    @State private var newTitle: String
    @State private var newDuration: GoalDuration

    // Show update confirmation.
    @State private var showConfirmation = false

    // MARK: - Setup

    init(
        viewModel: LearningViewModel,
        isNewGoal: Bool = false
    ) {
        self.viewModel = viewModel
        self.isNewGoal = isNewGoal

        // Set the goal title.
        _newTitle = State(
            initialValue: isNewGoal
                ? ""
                : (viewModel.currentGoal?.title ?? "")
        )

        // Set the goal duration.
        _newDuration = State(
            initialValue: isNewGoal
                ? .Week
                : (viewModel.currentGoal?.duration ?? .Week)
        )
    }

    // MARK: - Form Validation

    // Check if the title is valid.
    private var canSave: Bool {
        !newTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }

    // Check if the goal changed.
    private var hasChanges: Bool {
        let cleanTitle = newTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard let goal = viewModel.currentGoal else {
            return false
        }

        return goal.title != cleanTitle ||
               goal.duration != newDuration
    }

    // MARK: - Main View

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Header

            HStack {

                // Close button.
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glassEffect(.regular, in: Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                // Page title.
                Text("Learning Goal")
                    .font(.system(size: 16, weight: .medium))

                Spacer()

                // Save button.
                Button {
                    if isNewGoal {
                        viewModel.startNewGoal(
                            title: newTitle,
                            duration: newDuration
                        )
                        dismiss()
                    } else if hasChanges {
                        showConfirmation = true
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Color.orange,
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
            }

            // MARK: - Goal Title

            VStack(alignment: .leading, spacing: 10) {

                Text("I want to learn")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)

                // Goal name input.
                TextField(
                    "Swift",
                    text: $newTitle
                )
                .font(.system(size: 17))
                .foregroundStyle(.white)
                .tint(.orange)
                .padding(.vertical, 12)

                Divider()
                    .overlay(Color.gray.opacity(0.3))
            }
            .padding(.top, 40)

            // MARK: - Duration Selection

            VStack(alignment: .leading, spacing: 12) {

                Text("I want to learn it in a")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)

                // Week, Month, and Year buttons.
                HStack(spacing: 10) {

                    ForEach(
                        GoalDuration.allCases,
                        id: \.self
                    ) { duration in

                        DurationButton(
                            title: duration.rawValue,
                            isSelected: newDuration == duration,
                            buttonWidth: duration.buttonWidth
                        ) {
                            newDuration = duration
                        }
                    }
                }
            }
            .padding(.top, 28)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)

        // Keep this sheet dark.
        .background(Color.black.ignoresSafeArea())
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)

        .presentationSizing(.page)
        .toolbar(.hidden, for: .navigationBar)

        
        // MARK: - Update Confirmation
        .tint(.orange)
       .alert("Update goal", isPresented: $showConfirmation) {

           Button("Dismiss", role: .cancel) {
               // Keep the current goal.
           }

           Button("Update") {
               viewModel.updateGoal(
                   title: newTitle,
                   duration: newDuration
               )
               dismiss()
                
           }
           .keyboardShortcut(.defaultAction)
         
       } message: {
           Text("If you update now, your streak will start over.")
       }

    }
}
