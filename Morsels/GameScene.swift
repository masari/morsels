import SpriteKit
import GameplayKit

// MARK: - Physics Categories
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let pig: UInt32 = 0b1 // 1
    static let flame: UInt32 = 0b10 // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Configuration Constants
    
    /// Layout and positioning constants
    private struct Layout {
        static let grillWidthRatio: CGFloat = 0.9
        static let grillHeightRatio: CGFloat = 0.2
        static let grillFlameAreaHeightRatio: CGFloat = 0.9
        static let grillFlameAreaHeight: CGFloat = 20.0
        static let grillFlameCenterYOffset: CGFloat = -0.07
        
        static let pigContactThreshold: CGFloat = 0.25 // Bottom 25% of screen
        static let pigSpawnTopMargin: CGFloat = 10.0
        
        static let scoreLabelRightMargin: CGFloat = 20.0
        static let scoreLabelTopMargin: CGFloat = 20.0
        
        static let progressLabelLeftMargin: CGFloat = 20.0
        static let progressLabelTopMargin: CGFloat = 20.0
        
        static let failureIndicatorSpacing: CGFloat = 5.0
        static let failureIndicatorBottomOffset: CGFloat = 20.0
    }
    
    /// Physics constants
    private struct Physics {
        static let gravity = CGVector(dx: 0, dy: -0.4)
        static let edgeFriction: CGFloat = 0.0
        
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
    
    /// Timing constants
    private struct Timing {
        static let nextRoundDelay: TimeInterval = 5.0
        static let gameOverDelay: TimeInterval = 1.0
        static let morseStartMinDelay: TimeInterval = 0.5
        static let morseEndBuffer: TimeInterval = 0.5
        
        static let pigRemovalDuration: TimeInterval = 0.3
        static let penaltyFlashInDuration: TimeInterval = 0.1
        static let penaltyFlashOutDuration: TimeInterval = 0.2
        static let scoreLabelFlashDuration: TimeInterval = 0.5
        static let progressLabelFlashDuration: TimeInterval = 1.0
        
        static let gameOverOverlayFadeDuration: TimeInterval = 0.5
    }
    
    /// Visual effects constants
    private struct Visual {
        static let backgroundColor = SKColor(red: 0.87, green: 0.94, blue: 1.0, alpha: 1.0)
        
        static let scoreLabelFontName = "Helvetica-Bold"
        static let scoreLabelFontSize: CGFloat = 24
        static let scoreLabelFontColor: UIColor = .black
        
        static let progressLabelFontName = "Helvetica"
        static let progressLabelFontSize: CGFloat = 16
        static let progressLabelFontColor: UIColor = .darkGray
        
        static let failureIndicatorFontSize: CGFloat = 30
        
        static let penaltyFlashColor: UIColor = .systemBlue
        static let penaltyFlashBlendFactor: CGFloat = 0.9
        
        static let scoreFlashColorStreak: UIColor = .purple
        static let scoreFlashColorPerfect: UIColor = .green
        static let scoreFlashColorPartial: UIColor = .orange
        
        static let progressFlashColor: UIColor = .green
        
        static let pigRemovalScaleFactor: CGFloat = 0.1
        
        static let gameOverOverlayAlpha: CGFloat = 0.7
        static let gameOverLabelFontName = "Helvetica-Bold"
        static let gameOverLabelFontSize: CGFloat = 48
        static let gameOverLabelFontColor: UIColor = .white
        static let gameOverLabelYOffset: CGFloat = 0.1
        
        static let finalScoreLabelFontName = "Helvetica"
        static let finalScoreLabelFontSize: CGFloat = 24
        static let finalScoreLabelFontColor: UIColor = .white
        
        static let restartLabelFontName = "Helvetica"
        static let restartLabelFontSize: CGFloat = 20
        static let restartLabelFontColor: UIColor = .white
        static let restartLabelYOffset: CGFloat = -0.1
    }
    
    /// Game rules constants
    private struct GameRules {
        static let maxFailedRounds = 3
        static let minSequenceLength = 1
        static let maxSequenceLength = 4
        
        static let pointsPerCorrectLetter = 10
        static let completionBonusPerBall = 50
        static let minBallsForBonus = 3
        
        static let streakBonusPoints = 25
        static let streakBonusInterval = 3
        
        static let masteryThreshold = 5
        static let minAccuracyForAdvancement: Double = 0.8
    }
    
    /// Z-Position layering constants
    private struct ZPosition {
        static let grillBackground: CGFloat = -1
        static let pigs: CGFloat = 0
        static let grillForeground: CGFloat = 1
        static let gameOverOverlay: CGFloat = 10
        static let gameOverLabels: CGFloat = 11
    }

    // MARK: - Properties
    
    // NEW: World node container
    private var worldNode: SKNode!
    
    // NEW: Safe area insets
    private var safeAreaInsets: UIEdgeInsets = .zero
    
    private var ballRadius: CGFloat = 40.0
    private var roundLetters: [Character] = []
    private var nextRoundScheduled = false
    private var isPenaltyActive = false
    
    // Game Over
    private var failedRoundsCounter = 0
    private var isGameOver = false
    private var failureIndicatorNodes: [SKLabelNode] = []
    
    // Scoring
    private var score: Int = 0
    private var scoreLabel: SKLabelNode!
    private var selectedOrder: [Character] = []
    
    // Streak Bonus
    private var perfectRoundStreak: Int = 0
    
    // Learning System
    private let letterProgression: [Character] = ["E", "T", "I", "A", "N", "M", "S", "U", "R", "W", "D", "K", "G", "O", "H", "V", "F", "L", "P", "J", "B", "X", "C", "Y", "Z", "Q"]
    private var currentLearningStage: Int = 0
    private var letterStats: [Character: (correct: Int, total: Int)] = [:]
    private var progressLabel: SKLabelNode!

    // Scene Nodes - Now layered
    private var grillBackground: SKSpriteNode!
    private var grillForeground: SKSpriteNode!
    
    weak var gameDelegate: GameSceneDelegate?

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = Visual.backgroundColor
        
        // NEW: Create world node first
        worldNode = SKNode()
        worldNode.name = "worldNode"
        addChild(worldNode)
        
        physicsWorld.gravity = Physics.gravity
        physicsWorld.contactDelegate = self
        
        let borderPath = CGMutablePath()
        borderPath.move(to: CGPoint(x: 0, y: 0))
        borderPath.addLine(to: CGPoint(x: 0, y: frame.height))
        borderPath.addLine(to: CGPoint(x: frame.width, y: frame.height))
        borderPath.addLine(to: CGPoint(x: frame.width, y: 0))
        physicsBody = SKPhysicsBody(edgeChainFrom: borderPath)
        physicsBody?.friction = Physics.edgeFriction

        setupBarbecueGrill()
        setupUI()
        
        initializeLearningStats()
        
        let pigSize = PigTextureGenerator.shared.recommendedPigSize
        ballRadius = pigSize.width / 2
        
        PigTextureGenerator.shared.preloadCommonLetters()
        startNextRound()
    }
    
    // MARK: - NEW: Safe Area Support
    
    /// Applies safe area insets to position the world node and adjust layout
    func applySafeAreaInsets(_ insets: UIEdgeInsets) {
        self.safeAreaInsets = insets
        
        // Adjust worldNode position to center content within safe area
        let verticalOffset = (insets.top - insets.bottom) / 2
        worldNode.position = CGPoint(x: 0, y: -verticalOffset)
        
        // Update UI element positions if they already exist
        updateUIPositions()
        updateGrillPosition()
    }
    
    private func updateUIPositions() {
        guard scoreLabel != nil, progressLabel != nil else { return }
        
        scoreLabel.position = CGPoint(
            x: size.width - Layout.scoreLabelRightMargin - safeAreaInsets.right,
            y: size.height - Layout.scoreLabelTopMargin - safeAreaInsets.top
        )
        
        progressLabel.position = CGPoint(
            x: Layout.progressLabelLeftMargin + safeAreaInsets.left,
            y: size.height - Layout.progressLabelTopMargin - safeAreaInsets.top
        )
        
        // Update failure indicators if they exist
        if !failureIndicatorNodes.isEmpty {
            updateFailureDisplay()
        }
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
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontName = Visual.scoreLabelFontName
        scoreLabel.fontSize = Visual.scoreLabelFontSize
        scoreLabel.fontColor = Visual.scoreLabelFontColor
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(
            x: size.width - Layout.scoreLabelRightMargin - safeAreaInsets.right,
            y: size.height - Layout.scoreLabelTopMargin - safeAreaInsets.top
        )
        worldNode.addChild(scoreLabel)
        
        progressLabel = SKLabelNode(text: updateProgressText())
        progressLabel.fontName = Visual.progressLabelFontName
        progressLabel.fontSize = Visual.progressLabelFontSize
        progressLabel.fontColor = Visual.progressLabelFontColor
        progressLabel.horizontalAlignmentMode = .left
        progressLabel.verticalAlignmentMode = .top
        progressLabel.position = CGPoint(
            x: Layout.progressLabelLeftMargin + safeAreaInsets.left,
            y: size.height - Layout.progressLabelTopMargin - safeAreaInsets.top
        )
        worldNode.addChild(progressLabel)
    }

    private func setupBarbecueGrill() {
        let grillSize = CGSize(
            width: size.width * Layout.grillWidthRatio,
            height: size.height * Layout.grillHeightRatio
        )
        
        // Generate the layered animation frames
        let (backgroundFrames, foregroundFrames) = BarbecueGrillGenerator.shared.generateLayeredAnimationFrames(size: grillSize, frameCount: 4)
        
        // --- Setup Background Layer (with Physics) ---
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
        
        // --- Setup Foreground Layer (Visual Only) ---
        grillForeground = SKSpriteNode(texture: foregroundFrames.first)
        grillForeground.name = "grill"
        grillForeground.size = grillSize
        grillForeground.position = grillBackground.position
        grillForeground.zPosition = ZPosition.grillForeground
        
        worldNode.addChild(grillForeground)
        
        // --- Run Synchronized Animations ---
        let backgroundAnimation = SKAction.animate(with: backgroundFrames, timePerFrame: 0.15)
        let foregroundAnimation = SKAction.animate(with: foregroundFrames, timePerFrame: 0.15)
        
        grillBackground.run(SKAction.repeatForever(backgroundAnimation))
        grillForeground.run(SKAction.repeatForever(foregroundAnimation))
    }
    
    // MARK: - Game Logic
    
    private func startNextRound() {
        nextRoundScheduled = true
        selectedOrder.removeAll()
        roundLetters = generateRoundLetters()
        
        let morseDuration = calculateMorseDuration(for: roundLetters)
        let morseStartDelay = max(
            Timing.morseStartMinDelay,
            Timing.nextRoundDelay - morseDuration - Timing.morseEndBuffer
        )
        
        let seq = SKAction.sequence([
            .wait(forDuration: morseStartDelay),
            .run { MorseCodePlayer.shared.play(letters: self.roundLetters) },
            .wait(forDuration: Timing.nextRoundDelay - morseStartDelay),
            .run { [weak self] in
                self?.spawnRoundBalls()
                self?.nextRoundScheduled = false
            }
        ])
        run(seq)
    }
    
    private func createPigBall(with letter: Character) {
        let pigSize = PigTextureGenerator.shared.recommendedPigSize
        let pigTexture = PigTextureGenerator.shared.generatePigTexture(for: letter, size: pigSize)
        let pigSprite = SKSpriteNode(texture: pigTexture)
        pigSprite.size = pigSize
        pigSprite.zPosition = ZPosition.pigs
        
        let radius = pigSize.width / 2
        pigSprite.position = CGPoint(
            x: CGFloat.random(in: radius...(size.width - radius)),
            y: size.height - radius - Layout.pigSpawnTopMargin - safeAreaInsets.top
        )
        pigSprite.name = "ball"
        pigSprite.userData = NSMutableDictionary()
        pigSprite.userData?["letter"] = String(letter)
        
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
        guard pigNode.parent != nil,
              pigNode.position.y < (size.height * Layout.pigContactThreshold) else { return }
        
        pigNode.physicsBody = nil
        createPuffOfSmoke(at: pigNode.position)
        pigNode.removeFromParent()
    }

    private func createPuffOfSmoke(at position: CGPoint) {
        let smokeEmitter = SKEmitterNode()
        smokeEmitter.particleTexture = ParticleTextureGenerator.shared.getSmokeTexture()
        smokeEmitter.particlePosition = position
        
        smokeEmitter.particleSize = CGSize(width: 100, height: 100)
        smokeEmitter.particleColor = .darkGray
        smokeEmitter.particleColorBlendFactor = 1.0
        smokeEmitter.particleAlpha = 1.0
        smokeEmitter.particleAlphaSpeed = -0.4
        smokeEmitter.particleBirthRate = 500
        smokeEmitter.particleLifetime = 2.5
        smokeEmitter.particleScale = 0.05
        smokeEmitter.particleScaleSpeed = 0.5
        smokeEmitter.particleSpeed = 60
        smokeEmitter.emissionAngleRange = .pi * 2
        
        worldNode.addChild(smokeEmitter)
        
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 2.5),
            SKAction.removeFromParent()
        ])
        smokeEmitter.run(removeAction)
    }

    // MARK: - Touches and Input Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restartGame()
            return
        }

        for touch in touches {
            let location = touch.location(in: worldNode)
            let touchedNode = worldNode.atPoint(location)
            if touchedNode.name == "grill" {
                gameDelegate?.pauseGame()
                return
            }
        }

        handleTouches(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        handleTouches(touches)
    }

    private func handleTouches(_ touches: Set<UITouch>) {
        guard !isPenaltyActive else { return }

        for touch in touches {
            let location = touch.location(in: worldNode)
            let ballNodes = worldNode.nodes(at: location).filter { $0.name == "ball" }
            
            for pigNode in ballNodes {
                guard let pigSprite = pigNode as? SKSpriteNode,
                      let letterString = pigSprite.userData?["letter"] as? String,
                      let tappedLetter = letterString.first,
                      pigSprite.userData?["isBeingRemoved"] as? Bool != true
                else { continue }
                
                if selectedOrder.count < roundLetters.count && tappedLetter == roundLetters[selectedOrder.count] {
                    pigSprite.userData?["isBeingRemoved"] = true
                    selectedOrder.append(tappedLetter)
                    
                    pigSprite.physicsBody = nil
                    
                    let disappearAction = SKAction.group([
                        .scale(to: Visual.pigRemovalScaleFactor, duration: Timing.pigRemovalDuration),
                        .fadeOut(withDuration: Timing.pigRemovalDuration)
                    ])
                    pigSprite.run(SKAction.sequence([disappearAction, .removeFromParent()]))
                } else {
                    triggerPenalty()
                    return
                }
            }
        }
    }
    
    private func triggerPenalty() {
        isPenaltyActive = true
        perfectRoundStreak = 0
        
        // Get the penalty duration from user settings
        let penaltyDuration = UserSettings.shared.penaltyDuration
        
        let turnBlue = SKAction.colorize(
            with: Visual.penaltyFlashColor,
            colorBlendFactor: Visual.penaltyFlashBlendFactor,
            duration: Timing.penaltyFlashInDuration
        )
        let restoreColor = SKAction.colorize(
            withColorBlendFactor: 0.0,
            duration: Timing.penaltyFlashOutDuration
        )
        let wait = SKAction.wait(forDuration: penaltyDuration)
        
        worldNode.children.filter { $0.name == "ball" }.forEach { $0.run(SKAction.sequence([turnBlue, wait, restoreColor])) }
        
        run(SKAction.sequence([
            .wait(forDuration: penaltyDuration + Timing.penaltyFlashOutDuration),
            .run { [weak self] in self?.isPenaltyActive = false }
        ]))
    }

    // MARK: - Game State and Update Loop
    
    override func update(_ currentTime: TimeInterval) {
        worldNode.children.forEach { node in
            if node.name == "ball" && node.position.y < -ballRadius {
                node.removeFromParent()
            }
        }
        
        if !nextRoundScheduled && worldNode.children.first(where: { $0.name == "ball" }) == nil {
            evaluateRound()
        }
    }
    
    private func evaluateRound() {
        updateLearningStats(selectedLetters: selectedOrder, correctLetters: roundLetters)
        
        var correctInSequence = 0
        for i in 0..<min(selectedOrder.count, roundLetters.count) {
            if selectedOrder[i] == roundLetters[i] {
                correctInSequence += 1
            } else {
                break
            }
        }
        
        if correctInSequence > 0 {
            failedRoundsCounter = 0
            updateScore(correctCount: correctInSequence)
        } else {
            perfectRoundStreak = 0
            failedRoundsCounter += 1
        }
        
        updateFailureDisplay()
        
        if failedRoundsCounter >= GameRules.maxFailedRounds {
            endGame()
        } else {
            checkForAdvancement()
            startNextRound()
        }
    }
    
    private func updateScore(correctCount: Int) {
        let sequencePoints = correctCount * GameRules.pointsPerCorrectLetter
        var totalPointsEarned = sequencePoints
        var isComplete = false
        var streakBonus = 0
        
        if correctCount == roundLetters.count {
            isComplete = true
            perfectRoundStreak += 1
            if roundLetters.count >= GameRules.minBallsForBonus {
                totalPointsEarned += GameRules.completionBonusPerBall * roundLetters.count
            }
            if perfectRoundStreak > 0 && perfectRoundStreak % GameRules.streakBonusInterval == 0 {
                streakBonus = GameRules.streakBonusPoints * perfectRoundStreak
                totalPointsEarned += streakBonus
            }
        } else {
            perfectRoundStreak = 0
        }
        
        score += totalPointsEarned
        scoreLabel.text = "Score: \(score)"
        
        let flashColor: UIColor = streakBonus > 0 ? Visual.scoreFlashColorStreak :
                                   (isComplete ? Visual.scoreFlashColorPerfect : Visual.scoreFlashColorPartial)
        let flashAction = SKAction.sequence([
            .run { self.scoreLabel.fontColor = flashColor },
            .wait(forDuration: Timing.scoreLabelFlashDuration),
            .run { self.scoreLabel.fontColor = Visual.scoreLabelFontColor }
        ])
        scoreLabel.run(flashAction)
    }
    
    private func endGame() {
        nextRoundScheduled = true
        run(SKAction.sequence([
            .wait(forDuration: Timing.gameOverDelay),
            .run { [weak self] in self?.showGameOver() }
        ]))
    }
    
    private func restartGame() {
        worldNode.children.filter { $0.name?.starts(with: "gameOver") ?? false }.forEach { $0.removeFromParent() }

        isGameOver = false
        score = 0
        failedRoundsCounter = 0
        perfectRoundStreak = 0
        selectedOrder.removeAll()
        
        initializeLearningStats()
        
        scoreLabel.text = "Score: \(score)"
        progressLabel.text = updateProgressText()
        updateFailureDisplay()
        
        startNextRound()
    }
    
    private func showGameOver() {
        isGameOver = true
        removeAllActions()

        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = .black
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = ZPosition.gameOverOverlay
        overlay.name = "gameOverOverlay"
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = Visual.gameOverLabelFontName
        gameOverLabel.fontSize = Visual.gameOverLabelFontSize
        gameOverLabel.fontColor = Visual.gameOverLabelFontColor
        gameOverLabel.position = CGPoint(x: 0, y: size.height * Visual.gameOverLabelYOffset)
        gameOverLabel.zPosition = ZPosition.gameOverLabels
        gameOverLabel.name = "gameOverLabel"
        
        let finalScoreLabel = SKLabelNode(text: "Final Score: \(score)")
        finalScoreLabel.fontName = Visual.finalScoreLabelFontName
        finalScoreLabel.fontSize = Visual.finalScoreLabelFontSize
        finalScoreLabel.fontColor = Visual.finalScoreLabelFontColor
        finalScoreLabel.position = .zero
        finalScoreLabel.zPosition = ZPosition.gameOverLabels
        finalScoreLabel.name = "gameOverLabel"
        
        let restartLabel = SKLabelNode(text: "Tap to Restart")
        restartLabel.fontName = Visual.restartLabelFontName
        restartLabel.fontSize = Visual.restartLabelFontSize
        restartLabel.fontColor = Visual.restartLabelFontColor
        restartLabel.position = CGPoint(x: 0, y: -size.height * Visual.restartLabelYOffset)
        restartLabel.zPosition = ZPosition.gameOverLabels
        restartLabel.name = "gameOverLabel"
        
        overlay.addChild(gameOverLabel)
        overlay.addChild(finalScoreLabel)
        overlay.addChild(restartLabel)
        worldNode.addChild(overlay)

        overlay.alpha = 0
        overlay.run(SKAction.fadeAlpha(to: Visual.gameOverOverlayAlpha, duration: Timing.gameOverOverlayFadeDuration))
        
        GameKitHelper.shared.submitScore(score, leaderboardID: GameKitHelper.leaderboardID)
    }
    
    // MARK: - Helper Methods
    
    private func updateFailureDisplay() {
        failureIndicatorNodes.forEach { $0.removeFromParent() }
        failureIndicatorNodes.removeAll()

        guard failedRoundsCounter > 0 else { return }

        let hamTemplate = SKLabelNode(text: "🍖")
        hamTemplate.fontSize = Visual.failureIndicatorFontSize
        let hamWidth = hamTemplate.frame.width
        let totalPossibleWidth = (CGFloat(GameRules.maxFailedRounds) * hamWidth) +
                                 (CGFloat(max(0, GameRules.maxFailedRounds - 1)) * Layout.failureIndicatorSpacing)
        let startX = (size.width - Layout.scoreLabelRightMargin - safeAreaInsets.right) - totalPossibleWidth

        for i in 0..<failedRoundsCounter {
            let hamLabel = SKLabelNode(text: "🍖")
            hamLabel.fontSize = Visual.failureIndicatorFontSize
            let xPos = startX + (hamWidth / 2) + (CGFloat(i) * (hamWidth + Layout.failureIndicatorSpacing))
            let yPos = scoreLabel.position.y - scoreLabel.frame.height - Layout.failureIndicatorBottomOffset
            hamLabel.position = CGPoint(x: xPos, y: yPos)
            worldNode.addChild(hamLabel)
            failureIndicatorNodes.append(hamLabel)
        }
    }
    
    private func initializeLearningStats() {
        currentLearningStage = min(UserSettings.shared.initialLearningStage, letterProgression.count - 1)
        for i in 0...currentLearningStage {
            letterStats[letterProgression[i]] = (correct: 0, total: 0)
        }
    }
    
    private func generateRoundLetters(allowDuplicates: Bool = false) -> [Character] {
        let availableLetters = Array(letterProgression[0...currentLearningStage])
        let count = Int.random(in: GameRules.minSequenceLength...min(GameRules.maxSequenceLength, availableLetters.count))
        
        if allowDuplicates {
            return (0..<count).compactMap { _ in availableLetters.randomElement() }
        } else {
            var uniqueLetters = availableLetters
            uniqueLetters.shuffle()
            return Array(uniqueLetters.prefix(count))
        }
    }
    
    private func updateProgressText() -> String {
        return "Learning: \(currentLearningStage + 1)/\(letterProgression.count) letters"
    }
    
    private func checkForAdvancement() {
        guard currentLearningStage < letterProgression.count - 1 else { return }
        
        let currentStageLetters = letterProgression[0...currentLearningStage]
        let canAdvance = currentStageLetters.allSatisfy { letter in
            guard let stats = letterStats[letter] else { return false }
            let accuracy = stats.total > 0 ? Double(stats.correct) / Double(stats.total) : 0.0
            return stats.correct >= GameRules.masteryThreshold && accuracy >= GameRules.minAccuracyForAdvancement
        }
        
        if canAdvance {
            currentLearningStage += 1
            let newLetter = letterProgression[currentLearningStage]
            letterStats[newLetter] = (correct: 0, total: 0)
            progressLabel.text = updateProgressText()
            
            let celebrateAction = SKAction.sequence([
                .run { self.progressLabel.fontColor = Visual.progressFlashColor },
                .wait(forDuration: Timing.progressLabelFlashDuration),
                .run { self.progressLabel.fontColor = Visual.progressLabelFontColor }
            ])
            progressLabel.run(celebrateAction)
        }
    }
    
    private func updateLearningStats(selectedLetters: [Character], correctLetters: [Character]) {
        for (index, letter) in correctLetters.enumerated() {
            if var stats = letterStats[letter] {
                stats.total += 1
                if index < selectedLetters.count && selectedLetters[index] == letter {
                    stats.correct += 1
                }
                letterStats[letter] = stats
            }
        }
    }

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
    
    private func spawnRoundBalls() {
        for letter in roundLetters {
            createPigBall(with: letter)
        }
    }
}
