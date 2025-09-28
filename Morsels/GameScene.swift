import SpriteKit
import GameplayKit

class GameScene: SKScene {

    private var ballRadius: CGFloat = 40.0  // Made mutable for device optimization
    private var roundLetters: [Character] = []
    // Tracks whether we've already scheduled the next round
    private var nextRoundScheduled = false
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
        
        // Create progress label
        progressLabel = SKLabelNode(text: updateProgressText())
        progressLabel.fontName = "Helvetica"
        progressLabel.fontSize = 16
        progressLabel.fontColor = .darkGray
        progressLabel.horizontalAlignmentMode = .left
        progressLabel.verticalAlignmentMode = .top
        progressLabel.position = CGPoint(x: 20, y: size.height - 20)
        addChild(progressLabel)

        // Initialize learning stats for starting letters
        initializeLearningStats()

        // Set up device-optimized pig size
        let pigSize = PigTextureGenerator.shared.recommendedPigSize
        let radius = pigSize.width / 2
        
        // Update ball radius for device
        ballRadius = radius

        // Preload pig textures for better performance
        PigTextureGenerator.shared.preloadCommonLetters(size: pigSize)

        // Register for memory warnings
        NotificationCenter.default.addObserver(
            PigTextureGenerator.shared,
            selector: #selector(PigTextureGenerator.handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

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

    // Initialize learning statistics
    private func initializeLearningStats() {
        // Start with first 3 letters
        currentLearningStage = min(2, letterProgression.count - 1)
        for i in 0...currentLearningStage {
            letterStats[letterProgression[i]] = (correct: 0, total: 0)
        }
    }
    
    // Generate letters based on current learning stage
    private func generateRoundLetters() -> [Character] {
        let availableLetters = Array(letterProgression[0...currentLearningStage])
        let count = Int.random(in: 1...min(4, availableLetters.count))
        return (0..<count).compactMap { _ in availableLetters.randomElement() }
    }
    
    // Update progress text for display
    private func updateProgressText() -> String {
        let availableCount = currentLearningStage + 1
        let totalCount = letterProgression.count
        return "Learning: \(availableCount)/\(totalCount) letters"
    }
    
    // Check if ready to advance to next learning stage
    private func checkForAdvancement() {
        guard currentLearningStage < letterProgression.count - 1 else { return }
        
        // Check if current letters are mastered
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
            
            // Visual feedback for new letter unlocked
            let celebrateAction = SKAction.sequence([
                .run { self.progressLabel.fontColor = .green },
                .wait(forDuration: 1.0),
                .run { self.progressLabel.fontColor = .darkGray }
            ])
            progressLabel.run(celebrateAction)
            
            print("🎉 New letter unlocked: \(newLetter)! Stage: \(currentLearningStage + 1)")
        }
    }
    
    // Update learning statistics
    private func updateLearningStats(selectedLetters: [Character], correctLetters: [Character]) {
        // Track statistics for each letter that was supposed to be selected
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
        let pigSprite = SKSpriteNode(pigWithLetter: letter, size: pigSize)
        
        let radius = pigSize.width / 2
        let xPos = CGFloat.random(in: radius...(size.width - radius))
        let yPos = size.height - radius - 10
        pigSprite.position = CGPoint(x: xPos, y: yPos)
        pigSprite.name = "ball"
        
        // Store the letter in userData for easy retrieval
        pigSprite.userData = NSMutableDictionary()
        pigSprite.userData?["letter"] = String(letter)
        
        // Add animated wings to make the pig fly
        PigWingAnimator.addAnimatedWings(to: pigSprite)
        
        // Physics body - using circular body for consistent physics
        let body = SKPhysicsBody(circleOfRadius: radius * 0.8) // Slightly smaller than visual size
        body.affectedByGravity = true
        body.restitution = 0.5
        body.linearDamping = CGFloat.random(in: 0.0...0.5)
        body.velocity = CGVector(dx: 0, dy: CGFloat.random(in: -50 ... -20))
        pigSprite.physicsBody = body
        
        // Add gentle floating motion to simulate flying
        let floatAction = SKAction.sequence([
            .moveBy(x: CGFloat.random(in: -15...15), y: CGFloat.random(in: -8...8), duration: 2.0 + Double.random(in: -0.5...0.5)),
            .moveBy(x: CGFloat.random(in: -15...15), y: CGFloat.random(in: -8...8), duration: 2.0 + Double.random(in: -0.5...0.5))
        ])
        let floatLoop = SKAction.repeatForever(floatAction)
        pigSprite.run(floatLoop, withKey: "float")
        
        // Add slight rotation for more dynamic movement
        let rotateAction = SKAction.sequence([
            .rotate(byAngle: CGFloat.random(in: -0.2...0.2), duration: 1.5 + Double.random(in: -0.3...0.3)),
            .rotate(byAngle: CGFloat.random(in: -0.2...0.2), duration: 1.5 + Double.random(in: -0.3...0.3))
        ])
        let rotateLoop = SKAction.repeatForever(rotateAction)
        pigSprite.run(rotateLoop, withKey: "rotate")
        
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
        for touch in touches {
            let location = touch.location(in: self)
            let hitNodes = nodes(at: location)
            
            // Process all pig balls at this location
            let ballNodes = hitNodes.filter { node in
                node.name == "ball"
            }
            
            for pigNode in ballNodes {
                guard let pigSprite = pigNode as? SKSpriteNode,
                      let letterString = pigSprite.userData?["letter"] as? String,
                      let letter = letterString.first else { continue }
                
                // Record the selection and remove the pig
                selectedOrder.append(letter)
                
                // Create a sparkle effect when pig is tapped
                createSparkleEffect(at: pigSprite.position)
                
                // Scale down and fade out the pig
                let disappearAction = SKAction.group([
                    .scale(to: 0.1, duration: 0.3),
                    .fadeOut(withDuration: 0.3),
                    .rotate(byAngle: CGFloat.pi * 2, duration: 0.3)
                ])
                
                let removeAction = SKAction.sequence([
                    disappearAction,
                    .removeFromParent()
                ])
                
                pigSprite.run(removeAction)
            }
        }
    }
    
    // Create sparkle effect for pig selection
    private func createSparkleEffect(at position: CGPoint) {
        for _ in 0..<8 {
            let sparkle = SKShapeNode(circleOfRadius: 3)
            sparkle.fillColor = .yellow
            sparkle.strokeColor = .orange
            sparkle.position = position
            sparkle.alpha = 1.0
            
            let randomAngle = CGFloat.random(in: 0...(2 * CGFloat.pi))
            let randomDistance = CGFloat.random(in: 20...40)
            let randomDuration = Double.random(in: 0.5...1.0)
            
            let moveAction = SKAction.move(
                by: CGVector(
                    dx: cos(randomAngle) * randomDistance,
                    dy: sin(randomAngle) * randomDistance
                ),
                duration: randomDuration
            )
            
            let fadeAction = SKAction.fadeOut(withDuration: randomDuration)
            let scaleAction = SKAction.scale(to: 0.1, duration: randomDuration)
            
            let combined = SKAction.group([moveAction, fadeAction, scaleAction])
            let sequence = SKAction.sequence([combined, .removeFromParent()])
            
            addChild(sparkle)
            sparkle.run(sequence)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Clean up any balls that fell off screen
        for case let ball as SKShapeNode in children where ball.name == "ball" {
            if ball.position.y < -ballRadius {
                ball.removeFromParent()
            }
        }
        
        // When all balls are gone, calculate partial credit for correct sequence
        let remaining = children.filter { $0.name == "ball" }
        if remaining.isEmpty && !nextRoundScheduled {
            // Update learning statistics
            updateLearningStats(selectedLetters: selectedOrder, correctLetters: roundLetters)
            
            // Calculate partial credit: points per correct letter in sequence
            var correctInSequence = 0
            for i in 0..<min(selectedOrder.count, roundLetters.count) {
                if selectedOrder[i] == roundLetters[i] {
                    correctInSequence += 1
                } else {
                    break // Stop at first incorrect letter
                }
            }
            
            if correctInSequence > 0 {
                let sequencePoints = correctInSequence * pointsPerCorrectLetter
                var totalPointsEarned = sequencePoints
                var isComplete = false
                var streakBonus = 0
                
                // Check for completion bonus
                if correctInSequence == roundLetters.count && roundLetters.count >= minBallsForBonus {
                    let completionBonus = completionBonusPerBall * roundLetters.count
                    totalPointsEarned += completionBonus
                    isComplete = true
                    print("Completion bonus: \(completionBonus) points (\(completionBonusPerBall) × \(roundLetters.count) balls)")
                }
                
                // Handle streak tracking and bonuses
                if correctInSequence == roundLetters.count {
                    // Perfect round - increment streak
                    perfectRoundStreak += 1
                    
                    // Check for streak bonus
                    if perfectRoundStreak > 0 && perfectRoundStreak % streakBonusInterval == 0 {
                        streakBonus = streakBonusPoints * perfectRoundStreak
                        totalPointsEarned += streakBonus
                        print("Streak bonus: \(streakBonus) points for \(perfectRoundStreak) perfect rounds!")
                    }
                } else {
                    // Not perfect - reset streak
                    perfectRoundStreak = 0
                }
                
                score += totalPointsEarned
                scoreLabel.text = "Score: \(score)"
                
                // Visual feedback - different colors for streaks, complete, or partial
                let flashColor: UIColor
                if streakBonus > 0 {
                    flashColor = .purple  // Purple for streak bonus
                } else if isComplete {
                    flashColor = .green   // Green for completion
                } else {
                    flashColor = .orange  // Orange for partial
                }
                
                let flashAction = SKAction.sequence([
                    .run { self.scoreLabel.fontColor = flashColor },
                    .wait(forDuration: 0.5),
                    .run { self.scoreLabel.fontColor = .black }
                ])
                scoreLabel.run(flashAction)
                
                print("Earned \(totalPointsEarned) points: \(sequencePoints) sequence + \(isComplete ? completionBonusPerBall * roundLetters.count : 0) completion + \(streakBonus) streak")
                print("Perfect round streak: \(perfectRoundStreak)")
            } else {
                // No points earned - reset streak
                perfectRoundStreak = 0
                print("Perfect round streak reset to 0")
            }
            
            // Check if ready to advance to next learning stage
            checkForAdvancement()
            
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