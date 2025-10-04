import SwiftUI

struct InstructionsView: View {
    // This closure will be used to communicate back to the UIKit host
    var onShowScoring: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("How to Play")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)

                InstructionRow(icon: "ear", text: "Listen carefully to the sequence of Morse code letters played at the start of each round.")
                InstructionRow(icon: "hand.tap.fill", text: "Tap the falling pigs in the same sequence you heard.")
                InstructionRow(icon: "checkmark.circle.fill", text: "Correct taps will save the pigs and send them to the pigpen.")
                InstructionRow(icon: "xmark.octagon.fill", text: "An incorrect tap will trigger a brief penalty where you cannot select any pigs.")
                InstructionRow(icon: "flame.fill", text: "Don't let the pigs fall into the grill! Too many failed rounds will end the game.")
                InstructionRow(icon: "pause.circle.fill", text: "Need a break? Tap the grill at any time to pause the game.")
                
                Spacer(minLength: 30)
                
                Button(action: {
                    // Trigger the callback
                    onShowScoring()
                }) {
                    Text("How Scoring Works")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(20)
        }
    }
}