import SwiftUI

struct ContentView: View {
    // The single source of truth for the game's state.
    @StateObject private var gameState = GameState()

    var body: some View {
        // A switch statement to determine which view to display.
        // This is the core of our app's navigation.
        switch gameState.currentScreen {
        case .splash:
            SplashScreenView()
                .environmentObject(gameState) // Pass the state to the splash screen
        case .playing:
            // Replace the placeholder with our new GameView
            GameView()
                .environmentObject(gameState)
        case .instructions:
            // Replace the placeholder with our new InstructionsView
            InstructionsView()
                .environmentObject(gameState)
        case .configuration:
            Text("Configuration Placeholder")
        }
    }
}