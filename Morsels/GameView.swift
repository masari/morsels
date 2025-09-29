import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    
    // We create an instance of our GameScene here.
    // By making it a private state variable, SwiftUI will manage its lifecycle.
    @State private var scene: GameScene = {
        let scene = GameScene()
        // Use .resizeFill to make the scene fill the available space
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .resizeFill
        return scene
    }()
    
    // A state variable to control the visibility of the pause menu.
    @State private var isPaused = false
    
    var body: some View {
        ZStack {
            // The SpriteView is the bridge between SwiftUI and SpriteKit.
            // It displays our scene.
            SpriteView(scene: scene)
                .ignoresSafeArea()
            
            // --- Pause Menu Overlay ---
            // This will only appear when `isPaused` is true.
            if isPaused {
                VStack(spacing: 20) {
                    Text("Paused")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Button("Continue") {
                        // Unpause the game and hide the menu
                        isPaused = false
                        scene.isPaused = false
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Quit") {
                        // Change the game state to go back to the splash screen
                        gameState.currentScreen = .splash
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.7))
            }
        }
        // This is where we will listen for the "pause" notification from the game scene.
        .onReceive(NotificationCenter.default.publisher(for: .pauseGame)) { _ in
            isPaused = true
            scene.isPaused = true
        }
    }
}

// Create a custom notification name for pausing the game.
// This is how our GameScene will communicate with our GameView.
extension Notification.Name {
    static let pauseGame = Notification.Name("pauseGame")
}