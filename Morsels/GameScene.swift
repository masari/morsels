import SpriteKit
import GameplayKit

class GameScene: SKScene {

    private let ballRadius: CGFloat = 30.0
    private var roundLetters: [Character] = []
    // Tracks whether we've already scheduled the next round
    private var nextRoundScheduled = false
    // Delay before playing Morse code for the next round
    private let nextRoundDelay: TimeInterval = 5.0
    
    // Scoring system
    private var score: Int = 0
    private var scoreLabel: SKLabelNode!
    private var selectedOrder: [Character] = []

    override func didMove(to view: SKView) {
        // White background so balls are clearly visible
        backgroundColor = .white

        // Gentle gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)

        // Scene boundary only at left, right, and top edges (not bottom)
        let borderPath = CGMutablePath()
        // Left edge
        borderPath.move(to: CGPoint(x: 0, y: 0))
        borderPath.addLine(to: CGPoint(x: 0, y: frame.height))
        // Top edge
        borderPath.addLine(to: CGPoint(x: frame.width, y: frame.height))
        // Right edge
        borderPath.addLine(to: CGPoint(x: frame.width, y: 0))
        // Note: we don't close the path to the bottom, leaving it open
        
        physicsBody = SKPhysicsBody(edgeChainFrom: borderPath)
        physicsBody?.friction = 0.0

        // Create and position score label in upper right corner
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(x: size.width - 20, y: size.height - 20)
        addChild(scoreLabel)

        // Start first round with same pattern as subsequent rounds
        nextRoundScheduled = true // Prevent update() from interfering with first round
        roundLetters = generateRoundLetters()
        let morseDuration = calculateMorseDuration(for: roundLetters)
        let morseStartDelay = max(0.5, nextRoundDelay - morseDuration - 0.5)
        
        let seq = SKAction.sequence([
            .wait(forDuration: morseStartDelay),
            .run { MorseCodePlayer.shared.play(letters: self.roundLetters) },
            .wait(forDuration: nextRoundDelay - morseStartDelay),
            .run { [weak self] in
                self?.spawnRoundBalls()
                self?.nextRoundScheduled = false // Now allow update() to manage subsequent rounds
            }
        ])
        run(seq)
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
            
            // Process all balls at this location (for smooth swiping)
            let ballNodes = hitNodes.filter { node in
                node.name == "ball" || node.parent?.name == "ball"
            }
            
            for node in ballNodes {
                var ballToRemove: SKNode?
                var selectedLetter: Character?
                
                // Find the ball and its letter
                if node.name == "ball" {
                    ballToRemove = node
                    if let label = node.children.compactMap({ $0 as? SKLabelNode }).first,
                       let text = label.text?.uppercased().first {
                        selectedLetter = text
                    }
                } else if node.parent?.name == "ball" {
                    ballToRemove = node.parent
                    if let text = (node as? SKLabelNode)?.text?.uppercased().first {
                        selectedLetter = text
                    }
                }
                
                // Record the selection and remove the ball
                if let ball = ballToRemove, let letter = selectedLetter {
                    selectedOrder.append(letter)
                    ball.removeFromParent()
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
        
        // When all balls are gone, check if they were selected in correct order
        let remaining = children.filter { $0.name == "ball" }
        if remaining.isEmpty && !nextRoundScheduled {
            // Check if player selected all balls in correct order
            if selectedOrder == roundLetters {
                score += 100
                scoreLabel.text = "Score: \(score)"
                // Optional: add visual feedback for correct answer
                let flashAction = SKAction.sequence([
                    .run { self.scoreLabel.fontColor = .green },
                    .wait(forDuration: 0.5),
                    .run { self.scoreLabel.fontColor = .black }
                ])
                scoreLabel.run(flashAction)
            }
            
            // Reset for next round
            selectedOrder.removeAll()
            
            nextRoundScheduled = true
            // Prepare next round letters and timings
            let newLetters = generateRoundLetters()
            let morseDuration = calculateMorseDuration(for: newLetters)
            roundLetters = newLetters
            
            // Calculate when to play Morse so it finishes right before balls spawn
            let morseStartDelay = max(0.5, nextRoundDelay - morseDuration - 0.5) // Play Morse near end of delay
            
            // Sequence: wait, play Morse, wait for Morse + remaining time, then spawn balls
            let seq = SKAction.sequence([
                .wait(forDuration: morseStartDelay),
                .run { MorseCodePlayer.shared.play(letters: newLetters) },
                .wait(forDuration: nextRoundDelay - morseStartDelay),
                .run { [weak self] in
                    self?.spawnRoundBalls()
                    self?.nextRoundScheduled = false
                }
            ])
            run(seq)
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
}