import SwiftUI

struct InstructionsView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            Color(red: 0.87, green: 0.94, blue: 1.0)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text("How to Play")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)

                InstructionRow(icon: "🐷", text: "**Goal:** Save the falling pigs from the fiery barbecue grill by sending them to the safety of their pigpen in the sky!")
                InstructionRow(icon: "👂", text: "**Listen:** At the start of each round, you will hear a sequence of letters tapped out in Morse code.")
                InstructionRow(icon: "👆", text: "**Tap:** Tap the pigs in the same order as the Morse code sequence you heard.")
                InstructionRow(icon: "⭐", text: "**Bonus:** Save all the pigs in the correct order for a big bonus!")
                InstructionRow(icon: "🔥", text: "**Watch Out:** A round is lost if you fail to save at least one pig, earning you a 🍖. Collect three 🍖 and the game is over!")

                Spacer()
                
                Button("Scoring Details") {
                    gameState.currentScreen = .scoring
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom, 10)

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