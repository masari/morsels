import SwiftUI

struct ScoringView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            Color(red: 0.87, green: 0.94, blue: 1.0)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text("Scoring Rules")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                
                InstructionRow(icon: "✅", text: "**Correct Pig:** +10 points for each pig tapped in the correct sequence.")
                InstructionRow(icon: "🏆", text: "**Perfect Round:** +50 points per pig if you save all of them in a round (minimum 3 pigs).")
                InstructionRow(icon: "🔥", text: "**Streak Bonus:** Every 3 perfect rounds in a row earns a streak bonus of +25 points, which increases with the streak!")
                
                Spacer()

                Button(action: {
                    gameState.currentScreen = .instructions
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back to Instructions")
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