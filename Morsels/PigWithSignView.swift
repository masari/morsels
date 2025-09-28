import SwiftUI

struct PigWithSignView: View {
    let letter: Character
    let size: CGSize
    @State private var wingsUp = false
    
    private let animationDuration: Double = 0.6
    
    var body: some View {
        ZStack {
            // Main pig body
            PigBodyView(size: size)
            
            // Animated wings
            PigWingsView(
                size: size,
                wingsUp: wingsUp
            )
            
            // Sign with letter
            PigSignView(
                letter: letter,
                size: size
            )
        }
        .frame(width: size.width, height: size.height)
        .onAppear {
            startWingAnimation()
        }
    }
    
    private func startWingAnimation() {
        withAnimation(
            Animation
                .easeInOut(duration: animationDuration)
                .repeatForever(autoreverses: true)
        ) {
            wingsUp = true
        }
    }
}

// MARK: - Pig Body
struct PigBodyView: View {
    let size: CGSize
    
    private var bodyWidth: CGFloat { size.width * 0.7 }
    private var bodyHeight: CGFloat { size.height * 0.6 }
    
    var body: some View {
        ZStack {
            // Main body
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [.pink.opacity(0.9), .pink.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: bodyWidth, height: bodyHeight)
                .overlay(
                    Ellipse()
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                )
            
            // Pig face
            PigFaceView(size: CGSize(width: bodyWidth * 0.8, height: bodyHeight * 0.6))
                .offset(y: -bodyHeight * 0.1)
            
            // Legs
            PigLegsView(bodyWidth: bodyWidth, bodyHeight: bodyHeight)
        }
    }
}

// MARK: - Pig Face
struct PigFaceView: View {
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Snout
            Ellipse()
                .fill(Color.pink.opacity(0.8))
                .frame(width: size.width * 0.4, height: size.height * 0.3)
                .offset(y: size.height * 0.1)
                .overlay(
                    // Nostrils
                    HStack(spacing: size.width * 0.05) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: size.width * 0.04, height: size.width * 0.04)
                        Circle()
                            .fill(Color.black)
                            .frame(width: size.width * 0.04, height: size.width * 0.04)
                    }
                    .offset(y: size.height * 0.1)
                )
            
            // Eyes
            HStack(spacing: size.width * 0.2) {
                PigEyeView(size: size.width * 0.15)
                PigEyeView(size: size.width * 0.15)
            }
            .offset(y: -size.height * 0.1)
            
            // Ears
            HStack(spacing: size.width * 0.6) {
                PigEarView(size: size.width * 0.2)
                    .rotationEffect(.degrees(-30))
                PigEarView(size: size.width * 0.2)
                    .rotationEffect(.degrees(30))
            }
            .offset(y: -size.height * 0.3)
        }
    }
}

// MARK: - Pig Eye
struct PigEyeView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // White of eye
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
            
            // Pupil
            Circle()
                .fill(Color.black)
                .frame(width: size * 0.6, height: size * 0.6)
            
            // Highlight
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.2, height: size * 0.2)
                .offset(x: -size * 0.1, y: -size * 0.1)
        }
        .overlay(
            Circle()
                .stroke(Color.black.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Pig Ear
struct PigEarView: View {
    let size: CGFloat
    
    var body: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [.pink.opacity(0.9), .pink.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size * 1.5)
            .overlay(
                Ellipse()
                    .stroke(Color.black.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Pig Legs
struct PigLegsView: View {
    let bodyWidth: CGFloat
    let bodyHeight: CGFloat
    
    var body: some View {
        HStack(spacing: bodyWidth * 0.3) {
            // Left legs
            VStack(spacing: bodyHeight * 0.1) {
                PigLegView(width: bodyWidth * 0.15, height: bodyHeight * 0.25)
                PigLegView(width: bodyWidth * 0.15, height: bodyHeight * 0.25)
            }
            
            // Right legs
            VStack(spacing: bodyHeight * 0.1) {
                PigLegView(width: bodyWidth * 0.15, height: bodyHeight * 0.25)
                PigLegView(width: bodyWidth * 0.15, height: bodyHeight * 0.25)
            }
        }
        .offset(y: bodyHeight * 0.4)
    }
}

// MARK: - Pig Leg
struct PigLegView: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: width * 0.5)
            .fill(Color.pink.opacity(0.8))
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: width * 0.5)
                    .stroke(Color.black.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Pig Wings
struct PigWingsView: View {
    let size: CGSize
    let wingsUp: Bool
    
    private var wingWidth: CGFloat { size.width * 0.3 }
    private var wingHeight: CGFloat { size.height * 0.4 }
    
    var body: some View {
        HStack(spacing: size.width * 0.4) {
            // Left wing
            PigWingView(
                width: wingWidth,
                height: wingHeight,
                isLeft: true
            )
            .rotationEffect(.degrees(wingsUp ? -45 : -15))
            .offset(x: size.width * 0.05, y: size.height * 0.05)
            
            // Right wing
            PigWingView(
                width: wingWidth,
                height: wingHeight,
                isLeft: false
            )
            .rotationEffect(.degrees(wingsUp ? 45 : 15))
            .offset(x: -size.width * 0.05, y: size.height * 0.05)
        }
    }
}

// MARK: - Individual Wing
struct PigWingView: View {
    let width: CGFloat
    let height: CGFloat
    let isLeft: Bool
    
    var body: some View {
        ZStack {
            // Wing shape - teardrop like
            Path { path in
                path.move(to: CGPoint(x: width * 0.5, y: 0))
                path.addQuadCurve(
                    to: CGPoint(x: 0, y: height * 0.7),
                    control: CGPoint(x: isLeft ? -width * 0.2 : width * 1.2, y: height * 0.3)
                )
                path.addQuadCurve(
                    to: CGPoint(x: width * 0.5, y: height),
                    control: CGPoint(x: width * 0.3, y: height * 0.9)
                )
                path.addQuadCurve(
                    to: CGPoint(x: width, y: height * 0.7),
                    control: CGPoint(x: width * 0.7, y: height * 0.9)
                )
                path.addQuadCurve(
                    to: CGPoint(x: width * 0.5, y: 0),
                    control: CGPoint(x: isLeft ? width * 1.2 : -width * 0.2, y: height * 0.3)
                )
            }
            .fill(
                LinearGradient(
                    colors: [.white.opacity(0.9), .gray.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Path { path in
                    path.move(to: CGPoint(x: width * 0.5, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: 0, y: height * 0.7),
                        control: CGPoint(x: isLeft ? -width * 0.2 : width * 1.2, y: height * 0.3)
                    )
                    path.addQuadCurve(
                        to: CGPoint(x: width * 0.5, y: height),
                        control: CGPoint(x: width * 0.3, y: height * 0.9)
                    )
                    path.addQuadCurve(
                        to: CGPoint(x: width, y: height * 0.7),
                        control: CGPoint(x: width * 0.7, y: height * 0.9)
                    )
                    path.addQuadCurve(
                        to: CGPoint(x: width * 0.5, y: 0),
                        control: CGPoint(x: isLeft ? width * 1.2 : -width * 0.2, y: height * 0.3)
                    )
                }
                .stroke(Color.black.opacity(0.3), lineWidth: 1)
            )
            
            // Wing feather details
            VStack(spacing: height * 0.05) {
                ForEach(0..<3, id: \.self) { i in
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(width: width * 0.6, height: 1)
                        .offset(y: CGFloat(i) * height * 0.15)
                }
            }
            .offset(y: height * 0.1)
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Pig Sign
struct PigSignView: View {
    let letter: Character
    let size: CGSize
    
    private var signWidth: CGFloat { size.width * 0.6 }
    private var signHeight: CGFloat { size.height * 0.4 }
    
    var body: some View {
        ZStack {
            // Sign post
            Rectangle()
                .fill(Color.brown)
                .frame(width: signWidth * 0.05, height: signHeight * 0.3)
                .offset(y: signHeight * 0.2)
            
            // Sign board
            RoundedRectangle(cornerRadius: signWidth * 0.05)
                .fill(Color.white)
                .frame(width: signWidth, height: signHeight * 0.6)
                .overlay(
                    RoundedRectangle(cornerRadius: signWidth * 0.05)
                        .stroke(Color.brown, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
            
            // Letter on sign
            Text(String(letter))
                .font(.system(size: min(signWidth * 0.6, signHeight * 0.4), weight: .bold, design: .rounded))
                .foregroundColor(.black)
        }
        .offset(y: size.height * 0.2)
    }
}

// MARK: - Preview
#if DEBUG
struct PigWithSignView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PigWithSignView(letter: "A", size: CGSize(width: 120, height: 120))
                .previewDisplayName("Pig with A")
                .padding()
            
            PigWithSignView(letter: "E", size: CGSize(width: 80, height: 80))
                .previewDisplayName("Small Pig with E")
                .padding()
            
            PigWithSignView(letter: "M", size: CGSize(width: 160, height: 160))
                .previewDisplayName("Large Pig with M")
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif