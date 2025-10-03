import UIKit
import SwiftUI

class InstructionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Create the SwiftUI view, passing a closure for navigation
        let swiftUIView = InstructionsView { [weak self] in
            self?.showScoringScreen()
        }
        
        // 2. Create a UIHostingController to host the SwiftUI view
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // 3. Add the hosting controller as a child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // 4. Set up constraints for the hosting controller's view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Set the title for the navigation bar
        self.title = "Instructions"
    }
    
    // This function will be called by the SwiftUI view's button
    private func showScoringScreen() {
        // Create the SwiftUI ScoringView
        let scoringView = ScoringView()
        // Host it in a UIHostingController
        let hostingController = UIHostingController(rootView: scoringView)
        hostingController.title = "Scoring Details"
        // Push it onto the navigation stack
        navigationController?.pushViewController(hostingController, animated: true)
    }
}