//
//  PhysicsCategory.swift
//  Morsels
//
//  Created by Mark Messer on 10/4/25.
//


//
//  GameScenePhysics.swift
//  Morsels
//
//  Handles physics setup and pig spawning
//

import SpriteKit

// MARK: - Physics Categories
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let pig: UInt32 = 0b1
    static let flame: UInt32 = 0b10
}

class GameScenePhysics {
    
    // MARK: - Configuration
    private struct Physics {
        static let gravity = CGVector(dx: 0, dy: -0.4)
        
        static let pigBodyCircleRadiusRatio: CGFloat = 0.35
        static let pigBodyCircleYOffset: CGFloat = -0.1
        static let pigBodyRectWidthRatio: CGFloat = 0.8
        static let pigBodyRectHeightRatio: CGFloat = 0.3
        static let pigBodyRectYOffset: CGFloat = 0.3
        
        static let pigRestitution: CGFloat = 0.4
        static let pigLinearDamping: CGFloat = 0.3
        static let pigAngularDamping: CGFloat = 0.8
        
        static let pigSpawnVelocityXRange: ClosedRange<CGFloat> = -15...15
        static let pigSpawnVelocityYRange: ClosedRange<CGFloat> = -40...(-15)
        static let pigSpawnAngularVelocityRange: ClosedRange<CGFloat> = -0.5...0.5
    }
    
    private struct Layout {
        static let pigSpawnTopMargin: CGFloat = 10.0
        static let pigContactThreshold: CGFloat = 0.25
    }
    
    private struct ZPosition {
        static let pigs: CGFloat = 0
    }
    
    // MARK: - Properties
    private weak var worldNode: SKNode?
    private let sceneSize: CGSize
    private var safeAreaInsets: UIEdgeInsets
    private let ballRadius: CGFloat
    
    // MARK: - Initialization
    init(worldNode: SKNode, sceneSize: CGSize, safeAreaInsets: UIEdgeInsets) {
        self.worldNode = worldNode
        self.sceneSize = sceneSize
        self.safeAreaInsets = safeAreaInsets
        
        let pigSize = PigTextureGenerator.shared.recommendedPigSize
        self.ballRadius = pigSize.width / 2
    }
    
    // MARK: - Physics World Setup
    func setupPhysicsWorld(for scene: SKScene) {
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -UserSettings.shared.pigGravity)

        let borderPath = CGMutablePath()
        borderPath.move(to: CGPoint(x: 0, y: 0))
        borderPath.addLine(to: CGPoint(x: 0, y: sceneSize.height))
        borderPath.addLine(to: CGPoint(x: sceneSize.width, y: sceneSize.height))
        borderPath.addLine(to: CGPoint(x: sceneSize.width, y: 0))
        scene.physicsBody = SKPhysicsBody(edgeChainFrom: borderPath)
        scene.physicsBody?.friction = 0.0
    }
    
    // MARK: - Safe Area Updates
    func updateSafeAreaInsets(_ insets: UIEdgeInsets) {
        self.safeAreaInsets = insets
    }
    
    // MARK: - Pig Spawning
    func spawnPig(with letter: Character) {
        guard let worldNode = worldNode else { return }
        
        let pigSize = PigTextureGenerator.shared.recommendedPigSize
        let pigTexture = PigTextureGenerator.shared.generatePigTexture(for: letter, size: pigSize)
        let pigSprite = SKSpriteNode(texture: pigTexture)
        pigSprite.size = pigSize
        pigSprite.zPosition = ZPosition.pigs
        
        let radius = pigSize.width / 2
        pigSprite.position = CGPoint(
            x: CGFloat.random(in: radius...(sceneSize.width - radius)),
            y: sceneSize.height - radius - Layout.pigSpawnTopMargin - safeAreaInsets.top
        )
        pigSprite.name = "ball"
        pigSprite.userData = NSMutableDictionary()
        pigSprite.userData?["letter"] = String(letter)
        
        // Create compound physics body
        let bodyCircle = SKPhysicsBody(
            circleOfRadius: pigSize.width * Physics.pigBodyCircleRadiusRatio,
            center: CGPoint(x: 0, y: pigSize.height * Physics.pigBodyCircleYOffset)
        )
        let bodyRectangle = SKPhysicsBody(
            rectangleOf: CGSize(
                width: pigSize.width * Physics.pigBodyRectWidthRatio,
                height: pigSize.height * Physics.pigBodyRectHeightRatio
            ),
            center: CGPoint(x: 0, y: pigSize.height * Physics.pigBodyRectYOffset)
        )
        let body = SKPhysicsBody(bodies: [bodyCircle, bodyRectangle])
        
        body.affectedByGravity = true
        body.restitution = Physics.pigRestitution
        body.linearDamping = Physics.pigLinearDamping
        body.angularDamping = Physics.pigAngularDamping
        body.velocity = CGVector(
            dx: CGFloat.random(in: Physics.pigSpawnVelocityXRange),
            dy: CGFloat.random(in: Physics.pigSpawnVelocityYRange)
        )
        body.angularVelocity = CGFloat.random(in: Physics.pigSpawnAngularVelocityRange)
        
        body.categoryBitMask = PhysicsCategory.pig
        body.contactTestBitMask = PhysicsCategory.flame
        body.collisionBitMask = 0xFFFFFFFF
        
        pigSprite.physicsBody = body
        worldNode.addChild(pigSprite)
    }
    
    // MARK: - Collision Detection Helpers
    func shouldHandlePigFlameContact(pigNode: SKSpriteNode, contactPoint: CGPoint) -> Bool {
        guard pigNode.parent != nil,
              pigNode.position.y < (sceneSize.height * Layout.pigContactThreshold) else {
            return false
        }
        return true
    }
    
    // MARK: - Cleanup
    func removeOffscreenPigs(from worldNode: SKNode) {
        worldNode.children.forEach { node in
            if node.name == "ball" && node.position.y < -ballRadius {
                node.removeFromParent()
            }
        }
    }
    
    func getAllPigs(from worldNode: SKNode) -> [SKSpriteNode] {
        return worldNode.children.compactMap { node in
            guard node.name == "ball", let sprite = node as? SKSpriteNode else { return nil }
            return sprite
        }
    }
    
    func getPigsAtLocation(_ location: CGPoint, in worldNode: SKNode) -> [SKSpriteNode] {
        return worldNode.nodes(at: location).compactMap { node in
            guard node.name == "ball", let sprite = node as? SKSpriteNode else { return nil }
            return sprite
        }
    }
}
