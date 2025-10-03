import SwiftUI

struct ScoringView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Scoring")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)

                InstructionRow(icon: "10.circle", text: "You get 10 points for each correctly tapped pig in sequence.")
                InstructionRow(icon: "star.fill", text: "Completing a full sequence perfectly earns a completion bonus of 50 points per pig.")
                InstructionRow(icon: "arrow.up.circle.fill", text: "Achieve a streak of 3 perfect rounds for a streak bonus that grows over time.")
                InstructionRow(icon: "hand.thumbsdown.fill", text: "Failing to tap any pigs in the correct sequence will count as a failed round.")
            }
            .padding(20)
        }
    }
}