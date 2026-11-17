
//
//  DurationButtons.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//

import SwiftUI

// MARK: - Duration Button

// Reusable duration button.
struct DurationButton: View {

    // Button title.
    let title: String

    // Selected button state.
    let isSelected: Bool

    // Button width.
    let buttonWidth: CGFloat

    // Button action.
    let action: () -> Void

    var body: some View {

        // Duration selection button.
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(
                    isSelected ? .white : .gray
                )
        }
        .frame(width: buttonWidth, height: 46)
        .glassEffect(
            .regular.tint(
                isSelected ? .orange : .clear
            ),
            in: Capsule()
        )
    }
}
