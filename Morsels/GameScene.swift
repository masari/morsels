import SpriteKit
import GameplayKit

class GameScene: SKScene {

    private let ballRadius: CGFloat = 30.0

    override func didMove(to view: SKView) {
        // White background so balls are clearly visible
        backgroundColor = .white

        // Gentle gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)

        // Scene boundary at edges
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.friction = 0.0

        // Spawn initial balls
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
        ball.fillColor = .blue
        ball.strokeColor = .clear

        // Position just within top edge so it’s immediately visible
        let xPos = CGFloat.random(in: ballRadius...(size.width - ballRadius))
        let yPos = size.height - ballRadius - 10
        ball.position = CGPoint(x: xPos, y: yPos)
        ball.name = "ball"

        // Physics so it falls with varied speed
        let body = SKPhysicsBody(circleOfRadius: ballRadius)
        body.affectedByGravity = true
        body.restitution = 0.5
        body.linearDamping = CGFloat.random(in: 0.0...0.5)
        // give a mild random downward push
        let initialSpeed = CGFloat.random(in: -50 ... -20)
        body.velocity = CGVector(dx: 0, dy: initialSpeed)
        ball.physicsBody = body

        // Letter label
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let letter = String(letters.randomElement()!)
        let label = SKLabelNode(text: letter)
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
        // When all balls are gone, spawn a new wave
        let remaining = children.filter { $0.name == "ball" }
        if remaining.isEmpty {
            spawnBalls()
        }
    }
}