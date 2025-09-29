import SwiftUI

// An enum to define all possible screens in the game.
enum GameScreen {
    case splash
    case playing
    case instructions
    case configuration
}

// This class will manage the overall state of the game,
// allowing us to switch between different screens from anywhere in the app.
class GameState: ObservableObject {
    @Published var currentScreen: GameScreen = .splash
}