
import SwiftUI
import UIKit

@main
struct MyApp: App {
    init() {
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
                .tintColor = .orange
        }

    var body: some Scene {
        WindowGroup {
            ContentView()
             .preferredColorScheme(.dark)
        }
    }
}
