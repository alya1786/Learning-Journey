//
//  DailyActionButtons.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//
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

    var body: some View {
        VStack(spacing: 0) {

            Button(action: onLearned) {
                Text(status == .learned
                     ? "Logged as Learned"
                     : "Log as Learned")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        status == .learned ? .gray : .white
                    )
                    .frame(width: 272, height: 272)
                    .background(
                        status == .learned
                            ? Color(white: 0.12)
                            : Color(red: 1, green: 0.54, blue: 0.13),
                        in: Circle()
                    )
            }
            .disabled(isLogged)

            Spacer()
                .frame(height: 48)

            Button(action: onFreeze) {
                Text(status == .frozen
                     ? "Freezed for a day"
                     : "Freeze for a day")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 272, height: 46)
                    .background(
                        (isLogged || !canFreeze)
                            ? Color(white: 0.12)
                            : Color(red: 0.17, green: 0.78, blue: 0.94),
                        in: Capsule()
                    )
            }
            .disabled(isLogged || !canFreeze)

            Text("\(freezesUsed) out of \(freezeLimit) Freezes used")
                .font(.system(size: 13))
                .foregroundStyle(.gray)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
    }
}
