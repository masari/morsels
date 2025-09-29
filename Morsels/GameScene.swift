import SpriteKit
import GameplayKit

class GameScene: SKScene {

    private var ballRadius: CGFloat = 40.0  // Made mutable for device optimization
    private var roundLetters: [Character] = []
    // Tracks whether we've already scheduled the next round
    private var nextRoundScheduled = false
    private let penaltyDuration: TimeInterval = 1.0
    private var isPenaltyActive = false
    private let fallingSpeed: CGFloat = -0.4 // Configurable falling speed for pigs.
    // Delay before playing Morse code for the next round
    private let nextRoundDelay: TimeInterval = 5.0
    
    // Scoring system
    private var score: Int = 0
    private var scoreLabel: SKLabelNode!
    private var selectedOrder: [Character] = []
    
    // Configurable scoring parameters
    private let pointsPerCorrectLetter: Int = 10
    private let completionBonusPerBall: Int = 50
    private let minBallsForBonus: Int = 3
    
    // Streak bonus configuration
    private let streakBonusPoints: Int = 25
    private let streakBonusInterval: Int = 3  // Bonus every 3 perfect rounds
    private var perfectRoundStreak: Int = 0
    
    // Progressive learning system
    private let letterProgression: [Character] = ["E", "T", "I", "A", "N", "M", "S", "U", "R", "W", "D", "K", "G", "O", "H", "V", "F", "L", "P", "J", "B", "X", "C", "Y", "Z", "Q"]
    private var currentLearningStage: Int = 0
    private var letterStats: [Character: (correct: Int, total: Int)] = [:]
    private let masteryThreshold: Int = 5  // Need 5 correct attempts to master a letter
    private let minAccuracyForAdvancement: Double = 0.8  // 80% accuracy required
    
    // UI for learning progress
    private var progressLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        // Light sky blue background for better pig visibility
        backgroundColor = SKColor(red: 0.87, green: 0.94, blue: 1.0, alpha: 1.0)

        // Gentle gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: fallingSpeed)

        // Scene boundary only at left, right, and top edges (not bottom)
        let borderPath = CGMutablePath()
        borderPath.move(to: CGPoint(x: 0, y: 0))
        borderPath.addLine(to: CGPoint(x: 0, y: frame.height))
        borderPath.addLine(to: CGPoint(x: frame.width, y: frame.height))
        borderPath.addLine(to: CGPoint(x: frame.width, y: 0))
        
        physicsBody = SKPhysicsBody(edgeChainFrom: borderPath)
        physicsBody?.friction = 0.0

        // Score label
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(x: size.width - 20, y: size.height - 20)
        addChild(scoreLabel)
        
        // Progress label
        progressLabel = SKLabelNode(text: updateProgressText())
        progressLabel.fontName = "Helvetica"
        progressLabel.fontSize = 16
        progressLabel.fontColor = .darkGray
        progressLabel.horizontalAlignmentMode = .left
        progressLabel.verticalAlignmentMode = .top
        progressLabel.position = CGPoint(x: 20, y: size.height - 20)
        addChild(progressLabel)

        // Initialize learning stats
        initializeLearningStats()

        // Set up pig size
        let pigSize = PigTextureGenerator.shared.recommendedPigSize
        ballRadius = pigSize.width / 2

        // Preload textures
        PigTextureGenerator.shared.preloadCommonLetters()
        
        // Start the first round
        startNextRound()
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

    // Initialize learning statistics
    private func initializeLearningStats() {
        currentLearningStage = min(2, letterProgression.count - 1)
        for i in 0...currentLearningStage {
            letterStats[letterProgression[i]] = (correct: 0, total: 0)
        }
    }
    
    // Generate letters based on current learning stage
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
    
    // Update progress text for display
    private func updateProgressText() -> String {
        let availableCount = currentLearningStage + 1
        return "Learning: \(availableCount)/\(letterProgression.count) letters"
    }
    
    // Check if ready to advance to next learning stage
    private func checkForAdvancement() {
        guard currentLearningStage < letterProgression.count - 1 else { return }
        
        var canAdvance = true
        for i in 0...currentLearningStage {
            let letter = letterProgression[i]
            if let stats = letterStats[letter] {
                let accuracy = stats.total > 0 ? Double(stats.correct) / Double(stats.total) : 0.0
                if stats.correct < masteryThreshold || accuracy < minAccuracyForAdvancement {
                    canAdvance = false
                    break
                }
            } else {
                canAdvance = false
                break
            }
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
    
    // Update learning statistics
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
            createPigBall(with: letter)
        }
    }

    // Create and add a pig ball showing the given letter
    private func createPigBall(with letter: Character) {
        let pigSize = PigTextureGenerator.shared.recommendedPigSize
        let pigTexture = PigTextureGenerator.shared.generatePigTexture(for: letter, size: pigSize)
        let pigSprite = SKSpriteNode(texture: pigTexture)
        pigSprite.size = pigSize
        
        let radius = pigSize.width / 2
        let xPos = CGFloat.random(in: radius...(size.width - radius))
        let yPos = size.height - radius - 10
        pigSprite.position = CGPoint(x: xPos, y: yPos)
        pigSprite.name = "ball"
        
        pigSprite.userData = NSMutableDictionary()
        pigSprite.userData?["letter"] = String(letter)
        
        let bodyCenter = CGPoint(x: 0, y: -pigSize.height * 0.1)
        let bodyRadius = pigSize.width * 0.35
        let bodyCircle = SKPhysicsBody(circleOfRadius: bodyRadius, center: bodyCenter)
        
        let signSize = CGSize(width: pigSize.width * 0.8, height: pigSize.height * 0.3)
        let signCenter = CGPoint(x: 0, y: pigSize.height * 0.3)
        let bodyRectangle = SKPhysicsBody(rectangleOf: signSize, center: signCenter)

        let body = SKPhysicsBody(bodies: [bodyCircle, bodyRectangle])
        
        body.affectedByGravity = true
        body.restitution = 0.4
        body.linearDamping = 0.3
        body.angularDamping = 0.8
        body.velocity = CGVector(dx: CGFloat.random(in: -15...15), dy: CGFloat.random(in: -40 ... -15))
        body.angularVelocity = CGFloat.random(in: -0.5...0.5)
        pigSprite.physicsBody = body
        
        addChild(pigSprite)
    }

    // Handle taps and swipes
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }

    private func handleTouches(_ touches: Set<UITouch>) {
        guard !isPenaltyActive else { return }

        for touch in touches {
            let location = touch.location(in: self)
            let hitNodes = nodes(at: location)
            
            let ballNodes = hitNodes.filter { $0.name == "ball" }
            
            for pigNode in ballNodes {
                guard let pigSprite = pigNode as? SKSpriteNode,
                      let letterString = pigSprite.userData?["letter"] as? String,
                      let tappedLetter = letterString.first,
                      // Add a check to ensure the pig is not already being removed.
                      pigSprite.userData?["isBeingRemoved"] as? Bool != true
                else { continue }
                
                if selectedOrder.count < roundLetters.count && tappedLetter == roundLetters[selectedOrder.count] {
                    // Correct tap
                    
                    // Mark the pig so it cannot be tapped again during its animation.
                    pigSprite.userData?["isBeingRemoved"] = true
                    
                    selectedOrder.append(tappedLetter)
                    
                    let disappearAction = SKAction.group([
                        .scale(to: 0.1, duration: 0.3),
                        .fadeOut(withDuration: 0.3)
                    ])
                    pigSprite.run(SKAction.sequence([disappearAction, .removeFromParent()]))
                    
                } else {
                    // Incorrect tap
                    triggerPenalty()
                    return
                }
            }
        }
    }
    
    private func triggerPenalty() {
        // 1. Set the penalty state to active to block input.
        isPenaltyActive = true
        perfectRoundStreak = 0 // An incorrect tap always resets the streak.

        // 2. Apply the visual penalty to all pigs.
        let remainingPigs = children.filter { $0.name == "ball" }
        let turnBlue = SKAction.colorize(with: .systemBlue, colorBlendFactor: 0.9, duration: 0.1)
        let wait = SKAction.wait(forDuration: penaltyDuration)
        let restoreColor = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
        
        // Create the visual sequence for each pig.
        let penaltySequence = SKAction.sequence([turnBlue, wait, restoreColor])
        remainingPigs.forEach { pig in
            // Use a unique key for each pig's penalty animation to prevent conflicts.
            pig.run(penaltySequence, withKey: "penalty_\(pig.hash)")
        }

        // 3. Set a separate, reliable timer on the scene itself to end the penalty state.
        // This is decoupled from the pig animations and is guaranteed to run.
        let endPenaltySequence = SKAction.sequence([
            .wait(forDuration: penaltyDuration + 0.3), // Wait slightly longer than the visual effect
            .run { [weak self] in
                self?.isPenaltyActive = false
            }
        ])
        run(endPenaltySequence)
    }

    // Create sparkle effect for pig selection
    private func createSparkleEffect(at position: CGPoint) {
        // Implementation for creating a sparkle effect at a given position
    }

    override func update(_ currentTime: TimeInterval) {
        // Clean up any balls that fell off screen
        children.forEach { node in
            if node.name == "ball" && node.position.y < -ballRadius {
                node.removeFromParent()
            }
        }
        
        // When all balls are gone, check the sequence
        if !nextRoundScheduled && children.first(where: { $0.name == "ball" }) == nil {
            
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
                let sequencePoints = correctInSequence * pointsPerCorrectLetter
                var totalPointsEarned = sequencePoints
                var isComplete = false
                var streakBonus = 0
                
                if correctInSequence == roundLetters.count {
                    perfectRoundStreak += 1
                    if roundLetters.count >= minBallsForBonus {
                        let completionBonus = completionBonusPerBall * roundLetters.count
                        totalPointsEarned += completionBonus
                        isComplete = true
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
            } else {
                perfectRoundStreak = 0
            }
            
            checkForAdvancement()
            
            // Start the next round
            startNextRound()
        }
    }
}