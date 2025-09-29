import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let pig: UInt32 = 0b1
    static let flame: UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    private var ballRadius: CGFloat = 40.0
    private var roundLetters: [Character] = []
    private var nextRoundScheduled = false
    private let penaltyDuration: TimeInterval = 1.0
    private var isPenaltyActive = false
    private let fallingSpeed: CGFloat = -0.4
    
    private let maxFailedRounds = 3
    private var failedRoundsCounter = 0
    private var isGameOver = false
    private let gameOverDelay: TimeInterval = 1.0
    private var failureIndicatorNodes: [SKLabelNode] = []
    
    private let nextRoundDelay: TimeInterval = 5.0
    
    private var score: Int = 0
    private var scoreLabel: SKLabelNode!
    private var selectedOrder: [Character] = []
    private let pointsPerCorrectLetter: Int = 10
    private let completionBonusPerBall: Int = 50
    private let minBallsForBonus: Int = 3
    
    private let streakBonusPoints: Int = 25
    private let streakBonusInterval: Int = 3
    private var perfectRoundStreak: Int = 0
    
    private let letterProgression: [Character] = ["E", "T", "I", "A", "N", "M", "S", "U", "R", "W", "D", "K", "G", "O", "H", "V", "F", "L", "P", "J", "B", "X", "C", "Y", "Z", "Q"]
    private var currentLearningStage: Int = 0
    private var letterStats: [Character: (correct: Int, total: Int)] = [:]
    private let masteryThreshold: Int = 5
    private let minAccuracyForAdvancement: Double = 0.8
    private var progressLabel: SKLabelNode!

    private var grillBackground: SKSpriteNode!
    private var grillForeground: SKSpriteNode!

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.87, green: 0.94, blue: 1.0, alpha: 1.0)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: fallingSpeed)
        physicsWorld.contactDelegate = self
        
        let borderPath = CGMutablePath()
        borderPath.move(to: CGPoint(x: 0, y: 0))
        borderPath.addLine(to: CGPoint(x: 0, y: frame.height))
        borderPath.addLine(to: CGPoint(x: frame.width, y: frame.height))
        borderPath.addLine(to: CGPoint(x: frame.width, y: 0))
        physicsBody = SKPhysicsBody(edgeChainFrom: borderPath)
        physicsBody?.friction = 0.0

        setupBarbecueGrill()
        setupUI()
        
        initializeLearningStats()
        
        let pigSize = PigTextureGenerator.shared.recommendedPigSize
        ballRadius = pigSize.width / 2
        
        PigTextureGenerator.shared.preloadCommonLetters()
        startNextRound()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        // Determine the top safe area inset to avoid the notch.
        // We'll use a default padding of 20 if the safe area is not available.
        let topPadding = self.view?.safeAreaInsets.top ?? 20.0
        
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .top
        // Position the label relative to the safe area, not the screen edge.
        scoreLabel.position = CGPoint(x: size.width - 20, y: size.height - topPadding)
        addChild(scoreLabel)
        
        progressLabel = SKLabelNode(text: updateProgressText())
        progressLabel.fontName = "Helvetica"
        progressLabel.fontSize = 16
        progressLabel.fontColor = .darkGray
        progressLabel.horizontalAlignmentMode = .left
        progressLabel.verticalAlignmentMode = .top
        // Position the label relative to the safe area as well.
        progressLabel.position = CGPoint(x: 20, y: size.height - topPadding)
        addChild(progressLabel)
    }

    private func setupBarbecueGrill() {
        let grillSize = CGSize(width: size.width * 0.9, height: size.height * 0.2)
        
        let (backgroundFrames, foregroundFrames) = BarbecueGrillGenerator.shared.generateLayeredAnimationFrames(size: grillSize, frameCount: 4)
        
        grillBackground = SKSpriteNode(texture: backgroundFrames.first)
        grillBackground.size = grillSize
        grillBackground.position = CGPoint(x: size.width / 2, y: grillSize.height / 2)
        grillBackground.zPosition = -1
        grillBackground.name = "grill"
        
        let flameAreaHeight: CGFloat = 20.0
        let flameAreaSize = CGSize(width: grillSize.width * 0.9, height: flameAreaHeight)
        let centerY = (grillSize.height * -0.07) + (flameAreaHeight / 2)
        let flameBody = SKPhysicsBody(rectangleOf: flameAreaSize, center: CGPoint(x: 0, y: centerY))
        
        flameBody.isDynamic = false
        flameBody.categoryBitMask = PhysicsCategory.flame
        flameBody.contactTestBitMask = PhysicsCategory.pig
        flameBody.collisionBitMask = PhysicsCategory.none
        grillBackground.physicsBody = flameBody
        
        addChild(grillBackground)
        
        grillForeground = SKSpriteNode(texture: foregroundFrames.first)
        grillForeground.size = grillSize
        grillForeground.position = grillBackground.position
        grillForeground.zPosition = 1
        grillForeground.name = "grill"
        
        addChild(grillForeground)
        
        let backgroundAnimation = SKAction.animate(with: backgroundFrames, timePerFrame: 0.15)
        let foregroundAnimation = SKAction.animate(with: foregroundFrames, timePerFrame: 0.15)
        
        grillBackground.run(SKAction.repeatForever(backgroundAnimation))
        grillForeground.run(SKAction.repeatForever(foregroundAnimation))
    }
    
    private func startNextRound() {
        nextRoundScheduled = true
        selectedOrder.removeAll()
        roundLetters = generateRoundLetters()
        
        let morseDuration = calculateMorseDuration(for: roundLetters)
        let morseStartDelay = max(0.5, nextRoundDelay - morseDuration - 0.5)
        
        let seq = SKAction.sequence([
            .wait(forDuration: morseStartDelay),
            .run { MorseCodePlayer.shared.play(letters: self.roundLetters) },
            .wait(forDuration: nextRoundDelay - morseStartDelay),
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
        pigSprite.zPosition = 0 // Positioned between grill layers
        
        let radius = pigSize.width / 2
        pigSprite.position = CGPoint(x: CGFloat.random(in: radius...(size.width - radius)), y: size.height - radius - 10)
        pigSprite.name = "ball"
        pigSprite.userData = NSMutableDictionary()
        pigSprite.userData?["letter"] = String(letter)
        
        let bodyCircle = SKPhysicsBody(circleOfRadius: pigSize.width * 0.35, center: CGPoint(x: 0, y: -pigSize.height * 0.1))
        let bodyRectangle = SKPhysicsBody(rectangleOf: CGSize(width: pigSize.width * 0.8, height: pigSize.height * 0.3), center: CGPoint(x: 0, y: pigSize.height * 0.3))
        let body = SKPhysicsBody(bodies: [bodyCircle, bodyRectangle])
        
        body.affectedByGravity = true
        body.restitution = 0.4
        body.linearDamping = 0.3
        body.angularDamping = 0.8
        // Set horizontal velocity (dx) to 0 as you suggested.
        body.velocity = CGVector(dx: 0, dy: CGFloat.random(in: -40 ... -15))
        body.angularVelocity = CGFloat.random(in: -0.5...0.5)
        
        body.categoryBitMask = PhysicsCategory.pig
        body.contactTestBitMask = PhysicsCategory.flame
        body.collisionBitMask = 0xFFFFFFFF
        
        pigSprite.physicsBody = body
        addChild(pigSprite)
        
        // After a short delay, enable contact tests with the flame.
        let wait = SKAction.wait(forDuration: 0.5)
        let enableContact = SKAction.run {
            pigSprite.physicsBody?.contactTestBitMask = PhysicsCategory.flame
        }
        pigSprite.run(SKAction.sequence([wait, enableContact]))
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
                handlePigFlameContact(pigNode: pigNode)
            }
        }
    }
    
    private func handlePigFlameContact(pigNode: SKSpriteNode) {
        guard pigNode.parent != nil, pigNode.position.y < (size.height * 0.8) else { return }
        
        pigNode.physicsBody = nil
        
        createPuffOfSmoke(at: pigNode.position)
        
        pigNode.removeFromParent()
    }

    private func createPuffOfSmoke(at position: CGPoint) {
        let smokeEmitter = SKEmitterNode()
        smokeEmitter.particleTexture = ParticleTextureGenerator.shared.getSmokeTexture()
        smokeEmitter.particlePosition = position
        
        smokeEmitter.particleSize = CGSize(width: 80, height: 80)
        smokeEmitter.particleColor = .lightGray
        smokeEmitter.particleColorBlendFactor = 1.0
        smokeEmitter.particleAlpha = 0.9
        smokeEmitter.particleAlphaSpeed = -0.6
        smokeEmitter.particleBirthRate = 300
        smokeEmitter.particleLifetime = 2.0
        smokeEmitter.particleScale = 0.1
        smokeEmitter.particleScaleSpeed = 0.75
        smokeEmitter.particleSpeed = 40
        smokeEmitter.emissionAngleRange = .pi * 2
        
        addChild(smokeEmitter)
        
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 2.5),
            SKAction.removeFromParent()
        ])
        smokeEmitter.run(removeAction)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restartGame()
            return
        }

        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "grill" {
                NotificationCenter.default.post(name: .pauseGame, object: nil)
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
            let location = touch.location(in: self)
            let ballNodes = nodes(at: location).filter { $0.name == "ball" }
            
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
                    
                    let disappearAction = SKAction.group([.scale(to: 0.1, duration: 0.3), .fadeOut(withDuration: 0.3)])
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
        
        let turnBlue = SKAction.colorize(with: .systemBlue, colorBlendFactor: 0.9, duration: 0.1)
        let restoreColor = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
        let wait = SKAction.wait(forDuration: penaltyDuration)
        
        children.filter { $0.name == "ball" }.forEach { $0.run(SKAction.sequence([turnBlue, wait, restoreColor])) }
        
        run(SKAction.sequence([.wait(forDuration: penaltyDuration + 0.3), .run { [weak self] in self?.isPenaltyActive = false }]))
    }

    override func update(_ currentTime: TimeInterval) {
        children.forEach { node in
            if node.name == "ball" && node.position.y < -ballRadius {
                node.removeFromParent()
            }
        }
        
        if !nextRoundScheduled && children.first(where: { $0.name == "ball" }) == nil {
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
        
        if failedRoundsCounter >= maxFailedRounds {
            endGame()
        } else {
            checkForAdvancement()
            startNextRound()
        }
    }
    
    private func updateScore(correctCount: Int) {
        let sequencePoints = correctCount * pointsPerCorrectLetter
        var totalPointsEarned = sequencePoints
        var isComplete = false
        var streakBonus = 0
        
        if correctCount == roundLetters.count {
            isComplete = true
            perfectRoundStreak += 1
            if roundLetters.count >= minBallsForBonus {
                totalPointsEarned += completionBonusPerBall * roundLetters.count
            }
            if perfectRoundStreak > 0 && perfectRoundStreak % streakBonusInterval == 0 {
                streakBonus = streakBonusPoints * perfectRoundStreak
                totalPointsEarned += streakBonus
            }
        } else {
            perfectRoundStreak = 0
        }
        
        score += totalPointsEarned
        scoreLabel.text = "Score: \(score)"
        
        let flashColor: UIColor = streakBonus > 0 ? .purple : (isComplete ? .green : .orange)
        let flashAction = SKAction.sequence([
            .run { self.scoreLabel.fontColor = flashColor },
            .wait(forDuration: 0.5),
            .run { self.scoreLabel.fontColor = .black }
        ])
        scoreLabel.run(flashAction)
    }
    
    private func endGame() {
        nextRoundScheduled = true
        run(SKAction.sequence([.wait(forDuration: gameOverDelay), .run { [weak self] in self?.showGameOver() }]))
    }
    
    private func restartGame() {
        children.filter { $0.name?.starts(with: "gameOver") ?? false }.forEach { $0.removeFromParent() }

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
        overlay.zPosition = 10
        overlay.name = "gameOverOverlay"
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "Helvetica-Bold"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: 0, y: size.height * 0.1)
        gameOverLabel.zPosition = 11
        gameOverLabel.name = "gameOverLabel"
        
        let finalScoreLabel = SKLabelNode(text: "Final Score: \(score)")
        finalScoreLabel.fontName = "Helvetica"
        finalScoreLabel.fontSize = 24
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = .zero
        finalScoreLabel.zPosition = 11
        finalScoreLabel.name = "gameOverLabel"
        
        let restartLabel = SKLabelNode(text: "Tap to Restart")
        restartLabel.fontName = "Helvetica"
        restartLabel.fontSize = 20
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: 0, y: -size.height * 0.1)
        restartLabel.zPosition = 11
        restartLabel.name = "gameOverLabel"
        
        overlay.addChild(gameOverLabel)
        overlay.addChild(finalScoreLabel)
        overlay.addChild(restartLabel)
        addChild(overlay)

        overlay.alpha = 0
        overlay.run(SKAction.fadeAlpha(to: 0.7, duration: 0.5))
    }
    
    private func updateFailureDisplay() {
        failureIndicatorNodes.forEach { $0.removeFromParent() }
        failureIndicatorNodes.removeAll()

        guard failedRoundsCounter > 0 else { return }

        let hamTemplate = SKLabelNode(text: "🍖")
        hamTemplate.fontSize = 30
        let hamWidth = hamTemplate.frame.width
        let spacing: CGFloat = 5
        let totalPossibleWidth = (CGFloat(maxFailedRounds) * hamWidth) + (CGFloat(max(0, maxFailedRounds - 1)) * spacing)
        let startX = (size.width - 20) - totalPossibleWidth

        for i in 0..<failedRoundsCounter {
            let hamLabel = SKLabelNode(text: "🍖")
            hamLabel.fontSize = 30
            let xPos = startX + (hamWidth / 2) + (CGFloat(i) * (hamWidth + spacing))
            let yPos = scoreLabel.position.y - scoreLabel.frame.height - 20
            hamLabel.position = CGPoint(x: xPos, y: yPos)
            addChild(hamLabel)
            failureIndicatorNodes.append(hamLabel)
        }
    }
    
    private func initializeLearningStats() {
        currentLearningStage = min(2, letterProgression.count - 1)
        for i in 0...currentLearningStage {
            letterStats[letterProgression[i]] = (correct: 0, total: 0)
        }
    }
    
    private func generateRoundLetters(allowDuplicates: Bool = false) -> [Character] {
        let availableLetters = Array(letterProgression[0...currentLearningStage])
        let count = Int.random(in: 1...min(4, availableLetters.count))
        
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
            return stats.correct >= masteryThreshold && accuracy >= minAccuracyForAdvancement
        }
        
        if canAdvance {
            currentLearningStage += 1
            let newLetter = letterProgression[currentLearningStage]
            letterStats[newLetter] = (correct: 0, total: 0)
            progressLabel.text = updateProgressText()
            
            let celebrateAction = SKAction.sequence([
                .run { self.progressLabel.fontColor = .green },
                .wait(forDuration: 1.0),
                .run { self.progressLabel.fontColor = .darkGray }
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