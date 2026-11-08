import SwiftUI
import Playgrounds


enum GoalDuration: String,CaseIterable{
    case week
    case month
    case year
}

struct LearningGoal {
    let title: String
    let duration: GoalDuration
}


struct ContentView: View {
    
    @State private var learingTitle = ""
    @State private var selectedDuration: GoalDuration = .week

    func startLearning() {
        
    }
    
    var body: some View {
        VStack {
            
            
            Button("Start Learning") {
                startLearning()
            }
            
        }
    }
}














#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
