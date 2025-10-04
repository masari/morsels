//
//  GameScene.swift (Refactored)
//  Morsels
//
//  Coordinator that orchestrates game managers and scene components
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, GameSceneInputDelegate {

    // MARK: - Configuration Constants
    private struct Layout {
        static let grillWidthRatio: CGFloat = 0.9
        static let grillHeightRatio: CGFloat = 0.2
        static let grillFlameAreaHeightRatio: CGFloat = 0.9
        static let grillFlameAreaHeight: CGFloat = 20.0
        static let grillFlameCenterYOffset: CGFloat = -0.07
    }
    
    private struct Timing {
        static let nextRoundDelay: TimeInterval = 5.0
        static let gameOverDelay: TimeInterval = 1.0
        static let morseStartMinDelay: TimeInterval = 0.5
        static let morseEndBuffer: TimeInterval = 0.5
    }
    
    private struct Visual {
        static let backgroundColor = SKColor(red: 0.87, green: 0.94, blue: 1.0, alpha: 1.0)
    }
    
    private struct ZPosition {
        static let grillBackground: CGFloat = -1
        static let grillForeground: CGFloat = 1
    }
    
    // MARK: - Game Managers (Pure Logic)
    private let scoreManager = ScoreManager()
    private let progressionManager: LearningProgressionManager
    private let roundManager = RoundManager()
    
    // MARK: - Scene Components
    private var renderer: GameSceneRenderer!
    private var physics: GameScenePhysics!
    private var input: GameSceneInput!
    
    // MARK: - Scene Nodes
    private var worldNode: SKNode!
    private var grillBackground: SKSpriteNode!
    private var grillForeground: SKSpriteNode!
    
    // MARK: - State
    private var safeAreaInsets: UIEdgeInsets = .zero
    private var nextRoundScheduled = false
    private var isGameOver = false
    
    // MARK: - Delegate
    weak var gameDelegate: GameSceneDelegate?

    // MARK: - Initialization
    override init(size: CGSize) {
        // Initialize progression manager with user settings
        self.progressionManager = LearningProgressionManager(
            initialStage: UserSettings.shared.initialLearningStage
        )
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.progressionManager = LearningProgressionManager(
            initialStage: UserSettings.shared.initialLearningStage
        )
        super.init(coder: aDecoder)
    }

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = Visual.backgroundColor
        
        // Create world node
        worldNode = SKNode()
        worldNode.name = "worldNode"
        addChild(worldNode)
        
        // Initialize components
        renderer = GameSceneRenderer(worldNode: worldNode, sceneSize: size, safeAreaInsets: safeAreaInsets)
        physics = GameScenePhysics(worldNode: worldNode, sceneSize: size, safeAreaInsets: safeAreaInsets)
        input = GameSceneInput(worldNode: worldNode)
        input.delegate = self
        
        // Setup physics
        physicsWorld.contactDelegate = self
        physics.setupPhysicsWorld(for: self)
        
        // Setup grill
        setupBarbecueGrill()
        
        // Setup UI
        renderer.setupUI()
        renderer.updateScore(scoreManager.score)
        renderer.updateProgress(progressionManager.progressText)
        
        // Preload textures
        PigTextureGenerator.shared.preloadCommonLetters()
        
        // Start game
        startNextRound()
    }
    
    // MARK: - Safe Area Support
    func applySafeAreaInsets(_ insets: UIEdgeInsets) {
        self.safeAreaInsets = insets
        
        let verticalOffset = (insets.top - insets.bottom) / 2
        worldNode.position = CGPoint(x: 0, y: -verticalOffset)
        
        renderer.updateSafeAreaInsets(insets)
        physics.updateSafeAreaInsets(insets)
        updateGrillPosition()
    }
    
    private func updateGrillPosition() {
        guard grillBackground != nil, grillForeground != nil else { return }
        
        let grillSize = grillBackground.size
        let newPosition = CGPoint(
            x: size.width / 2,
            y: grillSize.height / 2 + safeAreaInsets.bottom
        )
        
        grillBackground.position = newPosition
        grillForeground.position = newPosition
    }
    
    // MARK: - Grill Setup
    private func setupBarbecueGrill() {
        let grillSize = CGSize(
            width: size.width * Layout.grillWidthRatio,
            height: size.height * Layout.grillHeightRatio
        )
        
        let (backgroundFrames, foregroundFrames) = BarbecueGrillGenerator.shared.generateLayeredAnimationFrames(
            size: grillSize,
            frameCount: 4
        )
        
        // Background layer (with physics)
        grillBackground = SKSpriteNode(texture: backgroundFrames.first)
        grillBackground.name = "grill"
        grillBackground.size = grillSize
        grillBackground.position = CGPoint(
            x: size.width / 2,
            y: grillSize.height / 2 + safeAreaInsets.bottom
        )
        grillBackground.zPosition = ZPosition.grillBackground
        
        let flameAreaSize = CGSize(
            width: grillSize.width * Layout.grillFlameAreaHeightRatio,
            height: Layout.grillFlameAreaHeight
        )
        let centerY = (grillSize.height * Layout.grillFlameCenterYOffset) + (Layout.grillFlameAreaHeight / 2)
        let flameBody = SKPhysicsBody(rectangleOf: flameAreaSize, center: CGPoint(x: 0, y: centerY))
        
        flameBody.isDynamic = false
        flameBody.categoryBitMask = PhysicsCategory.flame
        flameBody.contactTestBitMask = PhysicsCategory.pig
        flameBody.collisionBitMask = PhysicsCategory.none
        grillBackground.physicsBody = flameBody
        
        worldNode.addChild(grillBackground)
        
        // Foreground layer (visual only)
        grillForeground = SKSpriteNode(texture: foregroundFrames.first)
        grillForeground.name = "grill"
        grillForeground.size = grillSize
        grillForeground.position = grillBackground.position
        grillForeground.zPosition = ZPosition.grillForeground
        
        worldNode.addChild(grillForeground)
        
        // Animate both layers
        let backgroundAnimation = SKAction.animate(with: backgroundFrames, timePerFrame: 0.15)
        let foregroundAnimation = SKAction.animate(with: foregroundFrames, timePerFrame: 0.15)
        
        grillBackground.run(SKAction.repeatForever(backgroundAnimation))
        grillForeground.run(SKAction.repeatForever(foregroundAnimation))
    }
    
    // MARK: - Round Management
    private func startNextRound() {
        nextRoundScheduled = true
        
        let roundLetters = progressionManager.generateRoundLetters()
        roundManager.startRound(with: roundLetters)
        
        let morseDuration = calculateMorseDuration(for: roundLetters)
        let morseStartDelay = max(
            Timing.morseStartMinDelay,
            Timing.nextRoundDelay - morseDuration - Timing.morseEndBuffer
        )
        
        let seq = SKAction.sequence([
            .wait(forDuration: morseStartDelay),
            .run { MorseCodePlayer.shared.play(letters: roundLetters) },
            .wait(forDuration: Timing.nextRoundDelay - morseStartDelay),
            .run { [weak self] in
                self?.spawnRoundPigs()
                self?.nextRoundScheduled = false
            }
        ])
        run(seq)
    }
    
    private func spawnRoundPigs() {
        for letter in roundManager.roundLetters {
            physics.spawnPig(with: letter)
        }
    }
    
    private func evaluateRound() {
        // Update learning stats
        progressionManager.updateStats(
            selectedLetters: roundManager.selectedOrder,
            correctLetters: roundManager.roundLetters
        )
        
        // End round and check for failure
        roundManager.endRound()
        
        // Update score if had any correct
        if roundManager.hadAnyCorrect {
            let result = scoreManager.calculateRoundScore(
                correctCount: roundManager.correctInSequence,
                totalCount: roundManager.roundLetters.count
            )
            renderer.updateScore(scoreManager.score, flashType: result.flashType)
        } else {
            scoreManager.resetStreak()
        }
        
        // Update failure display
        renderer.updateFailureDisplay(count: roundManager.failedRoundsCount)
        
        // Check for game over
        if roundManager.isGameOver {
            endGame()
        } else {
            // Check for progression
            if progressionManager.checkForAdvancement() {
                renderer.updateProgress(progressionManager.progressText, didAdvance: true)
            }
            startNextRound()
        }
    }
    
    // MARK: - Game Over
    private func endGame() {
        isGameOver = true
        nextRoundScheduled = true
        
        run(SKAction.sequence([
            .wait(forDuration: Timing.gameOverDelay),
            .run { [weak self] in
                guard let self = self else { return }
                self.renderer.showGameOver(finalScore: self.scoreManager.score)
                GameKitHelper.shared.submitScore(self.scoreManager.score, leaderboardID: GameKitHelper.leaderboardID)
            }
        ]))
    }
    
    private func restartGame() {
        // Clear game over UI
        renderer.hideGameOver()
        
        // Reset all managers
        scoreManager.reset()
        progressionManager.reset(to: UserSettings.shared.initialLearningStage)
        roundManager.reset()
        input.reset()
        
        // Reset state
        isGameOver = false
        nextRoundScheduled = false
        
        // Update UI
        renderer.updateScore(scoreManager.score)
        renderer.updateProgress(progressionManager.progressText)
        renderer.updateFailureDisplay(count: 0)
        
        // Start fresh
        startNextRound()
    }
    
    // MARK: - Physics Contact Delegate
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & PhysicsCategory.pig != 0) &&
           (secondBody.categoryBitMask & PhysicsCategory.flame != 0) {
            if let pigNode = firstBody.node as? SKSpriteNode {
                handlePigFlameContact(pigNode: pigNode, contactPoint: contact.contactPoint)
            }
        }
    }
    
    private func handlePigFlameContact(pigNode: SKSpriteNode, contactPoint: CGPoint) {
        guard physics.shouldHandlePigFlameContact(pigNode: pigNode, contactPoint: contactPoint) else { return }
        
        pigNode.physicsBody = nil
        renderer.createSmokeEffect(at: pigNode.position)
        pigNode.removeFromParent()
    }
    
    // MARK: - GameSceneInputDelegate
    func didTapPig(letter: Character, sprite: SKSpriteNode) -> Bool {
        guard roundManager.isRoundActive else { return false }
        
        let wasCorrect = roundManager.selectLetter(letter)
        
        if wasCorrect {
            sprite.physicsBody = nil
            renderer.removePigWithAnimation(sprite)
        }
        
        return wasCorrect
    }
    
    func didTapGrill() {
        gameDelegate?.pauseGame()
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restartGame()
            return
        }
        
        _ = input.handleTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        _ = input.handleTouches(touches)
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        // Remove offscreen pigs
        physics.removeOffscreenPigs(from: worldNode)
        
        // Check if round is complete
        if !nextRoundScheduled && physics.getAllPigs(from: worldNode).isEmpty {
            evaluateRound()
        }
    }
    
    // MARK: - Helper Methods
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
}
