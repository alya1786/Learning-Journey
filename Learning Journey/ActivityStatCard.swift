//
//  ActivityStatCard.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//

import Foundation
import SwiftUI

struct ActivityStatCard: View {
    let icon: String
    let count: Int
    let title: String
    let color: Color

    var body: some View {
        
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)

            Text("\(count) \(count == 1 ? "day" : "days")")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .glassEffect(
            .regular,
            in: RoundedRectangle(cornerRadius: 28)
        )
    }
}

#Preview {
    HStack(spacing: 12) {
        ActivityStatCard(
            icon: "flame.fill",
            count: 0,
            title: "Learned",
            color: .orange
        )

        ActivityStatCard(
            icon: "snowflake",
            count: 0,
            title: "Freezed",
            color: .cyan
        )
    }
    .padding()
    .background(.black)
    .preferredColorScheme(.dark)
}
