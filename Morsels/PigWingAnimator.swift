import SpriteKit

class PigWingAnimator {
    
    /// Adds animated wings to a pig sprite node
    static func addAnimatedWings(to pigSprite: SKSpriteNode) {
        let pigSize = pigSprite.size
        
        // Create left wing
        let leftWing = createWingSprite(size: pigSize, isLeft: true)
        leftWing.position = CGPoint(x: -pigSize.width * 0.25, y: pigSize.height * 0.05)
        leftWing.name = "leftWing"
        pigSprite.addChild(leftWing)
        
        // Create right wing
        let rightWing = createWingSprite(size: pigSize, isLeft: false)
        rightWing.position = CGPoint(x: pigSize.width * 0.25, y: pigSize.height * 0.05)
        rightWing.name = "rightWing"
        pigSprite.addChild(rightWing)
        
        // Start flapping animation
        startFlappingAnimation(leftWing: leftWing, rightWing: rightWing)
    }
    
    private static func createWingSprite(size: CGSize, isLeft: Bool) -> SKSpriteNode {
        let wingSize = CGSize(width: size.width * 0.3, height: size.height * 0.4)
        let wingTexture = createWingTexture(size: wingSize)
        
        let wingSprite = SKSpriteNode(texture: wingTexture)
        wingSprite.size = wingSize
        wingSprite.anchorPoint = CGPoint(x: 0.5, y: 0.8) // Anchor near the top for rotation
        
        return wingSprite
    }
    
    private static func createWingTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            
            // Create wing shape (oval)
            let wingRect = CGRect(origin: .zero, size: size)
            ctx.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
            ctx.fillEllipse(in: wingRect)
            
            // Wing outline
            ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.3).cgColor)
            ctx.setLineWidth(1)
            ctx.strokeEllipse(in: wingRect)
            
            // Wing feather lines
            ctx.setStrokeColor(UIColor.black.withAlphaComponent(0.2).cgColor)
            ctx.setLineWidth(0.5)
            for i in 0..<3 {
                let y = size.height * 0.2 + CGFloat(i) * size.height * 0.2
                ctx.move(to: CGPoint(x: size.width * 0.2, y: y))
                ctx.addLine(to: CGPoint(x: size.width * 0.8, y: y))
                ctx.strokePath()
            }
        }
        
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        return texture
    }
    
    private static func startFlappingAnimation(leftWing: SKSpriteNode, rightWing: SKSpriteNode) {
        let flapDuration: TimeInterval = 0.6
        
        // Left wing animation
        let leftWingFlap = SKAction.sequence([
            .rotate(toAngle: -0.8, duration: flapDuration / 2),
            .rotate(toAngle: -0.2, duration: flapDuration / 2)
        ])
        let leftWingLoop = SKAction.repeatForever(leftWingFlap)
        leftWing.run(leftWingLoop, withKey: "flap")
        
        // Right wing animation (mirrored)
        let rightWingFlap = SKAction.sequence([
            .rotate(toAngle: 0.8, duration: flapDuration / 2),
            .rotate(toAngle: 0.2, duration: flapDuration / 2)
        ])
        let rightWingLoop = SKAction.repeatForever(rightWingFlap)
        rightWing.run(rightWingLoop, withKey: "flap")
    }
    
    /// Removes wings from a pig sprite
    static func removeWings(from pigSprite: SKSpriteNode) {
        pigSprite.childNode(withName: "leftWing")?.removeFromParent()
        pigSprite.childNode(withName: "rightWing")?.removeFromParent()
    }
}