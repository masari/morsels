import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @StateObject private var gameConfig = GameConfiguration()

    var body: some View {
        switch gameState.currentScreen {
        case .splash:
            SplashScreenView()
                .environmentObject(gameState)
                .environmentObject(gameConfig)
        case .playing:
            GameView()
                .environmentObject(gameState)
                .environmentObject(gameConfig)
        case .instructions:
            InstructionsView()
                .environmentObject(gameState)
        case .scoring:
            ScoringView()
                .environmentObject(gameState)
        case .configuration:
            ConfigurationView()
                .environmentObject(gameState)
                .environmentObject(gameConfig)
        }
    }
}