import SwiftUI

struct SplashScreenView: View {
    // Access the shared game state to change screens.
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            // A simple background color.
            Color(red: 0.87, green: 0.94, blue: 1.0)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Morsels")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // This button will change the game state to switch to the game scene.
                Button("Start Game") {
                    gameState.currentScreen = .playing
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                // Placeholder buttons for future screens
                Button("Instructions") {
                    gameState.currentScreen = .instructions
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Configuration") {
                    // gameState.currentScreen = .configuration
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}