import SpriteKit
import GameplayKit

class GameScene: SKScene {

    private let ballRadius: CGFloat = 30.0
    private var roundLetters: [Character] = []

    override func didMove(to view: SKView) {
        // White background so balls are clearly visible
        backgroundColor = .white

        // Gentle gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)

        // Scene boundary at edges
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.friction = 0.0

        // Determine letters for this round and play Morse code
        roundLetters = generateRoundLetters()
        MorseCodePlayer.shared.play(letters: roundLetters)
        // Delay spawning until after code finishes
        let totalDuration = calculateMorseDuration(for: roundLetters)
        run(.sequence([.wait(forDuration: totalDuration), .run { self.spawnRoundBalls() }]))
    }

    // Generate a random set of letters for the round
    private func generateRoundLetters() -> [Character] {
        let count = Int.random(in: 1...4)
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return (0..<count).compactMap { _ in alphabet.randomElement() }
    }

    // Calculate approximate total Morse code play duration
    private func calculateMorseDuration(for letters: [Character]) -> TimeInterval {
        let dot = 0.1, dash = 0.3, intra = dot, inter = dot * 3
        var duration: TimeInterval = 0
        for (i, ch) in letters.enumerated() {
            guard let code = MorseCodePlayer.shared.mapping[ch] else { continue }
            for symbol in code {
                duration += (symbol == "." ? dot : dash) + intra
            }
            if i < letters.count - 1 { duration += inter }
        }
        return duration
    }

    // Spawn balls for current round
    private func spawnRoundBalls() {
        for letter in roundLetters {
            createBall(with: letter)
        }
    }

    // Create and add a ball showing the given letter
    private func createBall(with letter: Character) {
        let ball = SKShapeNode(circleOfRadius: ballRadius)
        ball.fillColor = .blue
        ball.strokeColor = .clear
        let xPos = CGFloat.random(in: ballRadius...(size.width - ballRadius))
        let yPos = size.height - ballRadius - 10
        ball.position = CGPoint(x: xPos, y: yPos)
        ball.name = "ball"
        let body = SKPhysicsBody(circleOfRadius: ballRadius)
        body.affectedByGravity = true
        body.restitution = 0.5
        body.linearDamping = CGFloat.random(in: 0.0...0.5)
        body.velocity = CGVector(dx: 0, dy: CGFloat.random(in: -50 ... -20))
        ball.physicsBody = body
        let label = SKLabelNode(text: String(letter))
        label.fontName = "Helvetica-Bold"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        ball.addChild(label)
        addChild(ball)
    }

    // Handle taps and swipes
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }

    private func handleTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            let location = touch.location(in: self)
            let hitNodes = nodes(at: location)
            for node in hitNodes {
                // Remove the ball shape (parent of label) if hit
                if node.name == "ball" {
                    node.removeFromParent()
                } else if node.parent?.name == "ball" {
                    node.parent?.removeFromParent()
                }
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Clean up any balls that fell off screen
        for case let ball as SKShapeNode in children where ball.name == "ball" {
            if ball.position.y < -ballRadius {
                ball.removeFromParent()
            }
        }
        // When all balls are gone, spawn next round
        let remaining = children.filter { $0.name == "ball" }
        if remaining.isEmpty {
            spawnRoundBalls()
        }
    }

    /// Call this whenever you want to read out all active balls in Morse:
    func playActiveBallsInMorse() {
        // Gather letters from all balls currently in the scene
        let letters: [Character] = children.compactMap { node in
            guard node.name == "ball",
                  let lbl = node.children.compactMap({ $0 as? SKLabelNode }).first,
                  let text = lbl.text?.uppercased().first
            else { return nil }
            return text
        }
        // Play the sequence
        MorseCodePlayer.shared.play(letters: letters)
    }

    // Example: play code whenever user lifts finger off screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        playActiveBallsInMorse()
    }
}