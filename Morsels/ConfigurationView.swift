import SwiftUI

struct ConfigurationView: View {
    // This view will get access to the shared GameState to handle navigation.
    @EnvironmentObject var gameState: GameState
    // It will also get access to our new GameConfiguration object.
    @EnvironmentObject var gameConfig: GameConfiguration

    var body: some View {
        ZStack {
            // A neutral background color.
            Color(red: 0.9, green: 0.9, blue: 0.92)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Configuration")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                // --- Falling Speed Slider ---
                VStack(alignment: .leading) {
                    Text("Pig Falling Speed")
                        .font(.headline)
                    // The slider directly binds to the pigFallingSpeed property
                    // in our GameConfiguration object.
                    Slider(value: $gameConfig.pigFallingSpeed, in: -1.0...(-0.1), step: 0.1)
                    Text("Current: \(gameConfig.pigFallingSpeed, specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)

                Spacer()

                // --- Back Button ---
                Button(action: {
                    gameState.currentScreen = .splash
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back to Menu")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(30)
        }
    }
}