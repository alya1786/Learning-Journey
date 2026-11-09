//
//  LearningViewModel.swift
//  Learning Journey
//
//  Created by alya alansari on 09/11/2026.
//

import Foundation
import Observation

@Observable
class LearningViewModel{
    var learningTitle = ""
    var selectedDuration : GoalDuration = .Week
    var currentGoal : LearningGoal?
    var canStart: Bool{
        !learningTitle
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    func startLearning() {
        let cleanTitle = learningTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanTitle.isEmpty{
            let newGoal = LearningGoal(
                title: cleanTitle,
                duration: selectedDuration)
        currentGoal = newGoal
            
            
        }
}
    
    
}
