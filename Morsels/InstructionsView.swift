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

                InstructionRow(icon: "🐷", text: "**Goal:** Save the falling pigs from the fiery barbecue grill!")
                InstructionRow(icon: "👂", text: "**Listen:** At the start of each round, you will hear a sequence of letters tapped out in Morse code.")
                InstructionRow(icon: "👆", text: "**Tap:** Tap the pigs in the same order as the Morse code sequence you heard.")
                InstructionRow(icon: "⭐", text: "**Bonus:** Save all the pigs in the correct order for a big bonus!")
                InstructionRow(icon: "🔥", text: "**Watch Out:** If a pig falls into the grill, the round is over. Too many missed pigs, and the game ends!")

                Spacer()

                Button(action: {
                    // Change the game state to return to the splash screen
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

// A helper view to format each instruction row consistently.
struct InstructionRow: View {
    let icon: String
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text(icon)
                .font(.largeTitle)
            Text(text)
                .font(.body)
                .lineSpacing(5)
            Spacer()
        }
    }
}