//
//  DurationButtons.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//

import Foundation

import SwiftUI

struct DurationButton: View {
    let title: String
    let isSelected: Bool
    let buttonWidth: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(isSelected ? .white : .gray)
        }
        .frame(width: buttonWidth, height: 46)
        .glassEffect(
            .regular.tint(isSelected ? .orange : .clear),
            in: Capsule()
        )
        
    }
}
