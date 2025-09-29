import SwiftUI

// A helper view to format each instruction row consistently.
// By placing it in its own file, it can be shared by multiple views.
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