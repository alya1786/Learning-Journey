//
//  ActivitiesView.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//

import Foundation
import SwiftUI

struct ActivitiesView: View {
   
    let dailyLogs: [Date: DayStatus]
    
    @Environment(\.dismiss) private var dismiss
    
    private let calendar = Calendar.current
    
    private var months: [Date] {
        let calendar = Calendar.current

        guard let currentMonth = calendar.dateInterval(
            of: .month,
            for: Date()
        )?.start else {
            return []
        }

        return (0..<12).compactMap { offset in
            calendar.date(
                byAdding: .month,
                value: offset,
                to: currentMonth
            )
        }
    }
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .glassEffect(.regular, in: Circle())
                    }
                    
                    Spacer()
                    
                    Text("Activities")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                
                ScrollView {
                    LazyVStack(spacing: 18) {
                        ForEach(months, id: \.self) { month in
                            CalendarView(
                                month: month,
                                dailyLogs: dailyLogs
                            )
                            
                            Divider()
                                .overlay(Color.gray.opacity(0.3))
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .background(Color.black)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    #Preview {
        NavigationStack {
            ActivitiesView(dailyLogs: [:])
                .preferredColorScheme(.dark)
        }
    }
