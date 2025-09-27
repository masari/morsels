import SpriteKit
import GameplayKit

class GameScene: SKScene {

    private let ballRadius: CGFloat = 30.0

    override func didMove(to view: SKView) {
        // Set a mild downward gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -1)  // slower global drop
        // Add scene boundary so balls land on bottom edge
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.friction = 0.0

        // Start with a random batch
        spawnBalls()
    }

    // Spawn a random number (1–4) of balls
    private func spawnBalls() {
        let count = Int.random(in: 1...4)
        for _ in 0..<count {
            createBall()
        }
    }

    // Create and add one ball with a random letter
    private func createBall() {
        // Circle shape
        let ball = SKShapeNode(circleOfRadius: ballRadius)
        ball.fillColor = .cyan
        ball.strokeColor = .clear
        // Random X, just above top edge
        ball.position = CGPoint(
            x: CGFloat.random(in: ballRadius...(size.width - ballRadius)),
            y: size.height + ballRadius
        )
        ball.name = "ball"

        // Physics so it falls
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.restitution = 0.5
        ball.physicsBody?.linearDamping = CGFloat.random(in: 0.0...0.5)  // random damping for varied speed
        // random initial downward velocity for different speeds
        let initialSpeed = CGFloat.random(in: -200 ... -50)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: initialSpeed)

        // Letter label
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let letter = String(letters.randomElement()!)
        let label = SKLabelNode(text: letter)
        label.fontName = "Helvetica-Bold"
        label.fontSize = 20
        label.fontColor = .black
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
        // When all balls are gone, spawn a new wave
        let remaining = children.filter { $0.name == "ball" }
        if remaining.isEmpty {
            spawnBalls()
        }
    }
}