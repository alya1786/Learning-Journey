//
//  UpdateLearningGoalView.swift
//  Learning Journey
//
//  Created by alya alansari on 10/11/2026.
//

import Foundation
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
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .glassEffect(.regular, in: Circle())
                    }
                    
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
                                canSave ? Color.orange : Color.gray,
                                in: Circle()
                            )
                    }
                    .disabled(!canSave)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("I want to learn")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                    
                    TextField("What do you want to learn?", text: $newTitle)
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
                        ForEach(GoalDuration.allCases, id: \.self) { duration in
                            Button {
                                newDuration = duration
                            } label: {
                                Text(duration.rawValue)
                                    .font(.system(size: 14))
                                    .foregroundStyle(
                                        newDuration == duration
                                        ? .white
                                        : .gray
                                    )
                                    .padding(.horizontal, 20)
                                    .frame(height: 40)
                                    .background {
                                        if newDuration == duration {
                                            Capsule()
                                                .fill(Color.orange)
                                        } else {
                                            Capsule()
                                                .fill(Color.white.opacity(0.1))
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.top, 28)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .background(Color.black)
            .foregroundStyle(.white)
            .toolbar(.hidden, for: .navigationBar)
            
            
            .alert("Update goal", isPresented: $showConfirmation) {
                Button("Dismiss", role: .cancel) {}
                
                Button("Update") {
                    viewModel.updateGoal(
                        title: newTitle,
                        duration: newDuration
                    )
                    dismiss()
                }
            } message: {
                Text("If you update now, your streak will start over.")
            }
        }
    }
