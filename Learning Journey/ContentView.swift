import SwiftUI
import Playgrounds






struct ContentView: View {
    
    @State private var viewModel = LearningViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.currentGoal != nil {
                    ActivityView(viewModel: viewModel)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.orange)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 80)
                            .padding(.bottom, 80)
                        HStack(spacing: 0) {
                            Text("Hello ")
                                .fontWeight(.regular)
                            
                            Text("Learner")
                                .bold()
                        }
                        .font(.system(size: 34))
                        .foregroundStyle(.white)
                        
                        Text("This app will help you learn everyday!")
                            .font(.system(size: 17))
                            .foregroundStyle(.gray)
                            .padding(.bottom, 32)
                        Text("I want to learn")
                            .foregroundStyle(.white)
                            .font(.system(size: 16))
                        
                        TextField("Swift", text: $viewModel.learningTitle)
                            .textFieldStyle(.plain)
                        Divider()
                        
                        
                        VStack(alignment: .leading,spacing: 20) {
                            Text("I want to learn it in a")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                            
                            HStack{
                                DurationButton(
                                    title: "Week",
                                    isSelected: viewModel.selectedDuration == .Week,
                                    buttonWidth: 84)
                                {
                                    viewModel.selectedDuration = .Week
                                }
                                
                                DurationButton(
                                    title: "Month",
                                    isSelected: viewModel.selectedDuration == .Month,
                                    buttonWidth: 91)
                                {
                                    viewModel.selectedDuration = .Month
                                }
                                DurationButton(
                                    title: "Year",
                                    isSelected: viewModel.selectedDuration == .Year,
                                    buttonWidth: 75)
                                {
                                    viewModel.selectedDuration = .Year
                                }
                            }
                        }
                        
                        Spacer()
                        Button {
                            viewModel.startLearning()
                        } label: {
                            Text("Start Learning")
                        }
                        .font(.system(size: 19, weight: .semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .glassEffect(
                            .regular.tint(
                                viewModel.canStart ? .orange : .gray
                            ),
                            in: Capsule()
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(
                            viewModel.canStart ? Color.white : Color.gray
                        )
                        .disabled(!viewModel.canStart)
                        
                        Text("You can edit your desire later")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                        
                        
                    }
                    .padding(.horizontal, 16)
                }

            }
            
        }
        
    }
    
}












#Preview {
    ContentView()
}
