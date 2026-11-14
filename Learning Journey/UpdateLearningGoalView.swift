
import SwiftUI

struct UpdateLearningGoalView: View {

    @Environment(\.dismiss) private var dismiss

    @Bindable var viewModel: LearningViewModel

    var isNewGoal: Bool

    @State private var newTitle: String
    @State private var newDuration: GoalDuration
    @State private var showConfirmation = false

    init(
        viewModel: LearningViewModel,
        isNewGoal: Bool = false
    ) {
        self.viewModel = viewModel
        self.isNewGoal = isNewGoal

        _newTitle = State(
            initialValue: isNewGoal
                ? ""
                : (viewModel.currentGoal?.title ?? "")
        )

        _newDuration = State(
            initialValue: isNewGoal
                ? .Week
                : (viewModel.currentGoal?.duration ?? .Week)
        )
    }

    private var canSave: Bool {
        !newTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }

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

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            HStack {

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

                Text("Learning Goal")
                    .font(.system(size: 16, weight: .medium))

                Spacer()

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
                                canSave && (isNewGoal || hasChanges)
                                    ? Color.orange
                                    : Color.gray,
                                in: Circle()
                            )
                
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
            }

            VStack(alignment: .leading, spacing: 10) {

                Text("I want to learn")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)

                TextField(
                    "What do you want to learn?",
                    text: $newTitle
                )
                .font(.system(size: 16))
                .tint(.orange)
                .padding(.vertical, 12)

                Divider()
                    .overlay(Color.gray.opacity(0.3))
            }
            .padding(.top, 40)

            VStack(alignment: .leading, spacing: 12) {

                Text("I want to learn it in a")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)

                HStack(spacing: 10) {

                    DurationButton(
                        title: "Week",
                        isSelected: newDuration == .Week,
                        buttonWidth: 84
                    ) {
                        newDuration = .Week
                    }

                    DurationButton(
                        title: "Month",
                        isSelected: newDuration == .Month,
                        buttonWidth: 91
                    ) {
                        newDuration = .Month
                    }

                    DurationButton(
                        title: "Year",
                        isSelected: newDuration == .Year,
                        buttonWidth: 75
                    ) {
                        newDuration = .Year
                    }
                }
            }
            .padding(.top, 28)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .background(Color.black.ignoresSafeArea())
        .foregroundStyle(.white)
        .presentationSizing(.page)
        .toolbar(.hidden, for: .navigationBar)
            .overlay {
                if showConfirmation {
                    ZStack {
                        Color.black.opacity(0.55)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showConfirmation = false
                            }

                        VStack(alignment: .leading, spacing: 16) {
                            Text("Update goal")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)

                            Text("If you update now, your streak will start over.")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: 12) {
                                Button {
                                    showConfirmation = false
                                } label: {
                                    Text("Dismiss")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(
                                            Color(white: 0.22),
                                            in: Capsule()
                                        )
                                }

                                Button {
                                    showConfirmation = false

                                    viewModel.updateGoal(
                                        title: newTitle,
                                        duration: newDuration
                                    )

                                    dismiss()
                                } label: {
                                    Text("Update")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(
                                            Color.orange,
                                            in: Capsule()
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(20)
                        .frame(maxWidth: 310)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color(white: 0.11))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 28)
                                        .strokeBorder(
                                            Color.white.opacity(0.18),
                                            lineWidth: 1
                                        )
                                }
                        )
                        .shadow(color: .black.opacity(0.4), radius: 20)
                    }
                }
            }

        }
    }

