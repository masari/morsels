import SwiftUI

// This class will hold all configurable settings for the game.
// By making it an ObservableObject, our SwiftUI views can automatically
// update when these settings change.
class GameConfiguration: ObservableObject {
    // @Published notifies any listening views when the value changes.
    // We'll set a default value of -0.4 for the falling speed.
    @Published var pigFallingSpeed: Double = -0.4
}