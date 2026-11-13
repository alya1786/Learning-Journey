//
//  GoalResultView.swift
//  Learning Journey
//
//  Created by alya alansari on 10/11/2026.
//

import Foundation
import SwiftUI

struct GoalResultView: View {

    let result: LearningViewModel.GoalResult
    let onSetGoal: () -> Void

    private var isCompleted: Bool {
        result == .completed
    }

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            VStack(spacing: 12) {

                Image(
                    systemName: isCompleted
                    ? "hands.clap.fill"
                    : "xmark.seal"
                )
                .font(.system(size: 44))
                .foregroundStyle(.orange)
                .padding(.bottom, 16)

                Text(
                    isCompleted
                    ? "Well done!"
                    : "You didn't reach your goal this time."
                )
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

                Text(
                    isCompleted
                    ? "Ready for your next goal?"
                    : "Want to set another goal?"
                )
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            }

            Spacer()

            Button(action: onSetGoal) {
                Label("Set a goal", systemImage: "pencil.circle")
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(.orange, in: Capsule())
            }
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
    }
}
