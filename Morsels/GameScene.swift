//
//  GameScene.swift (Updated with Speech Recognition)
//  Morsels
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, GameSceneInputDelegate, SpeechRecognitionDelegate {

    // MARK: - Configuration Constants
    private struct Layout {
        static let grillWidthRatio: CGFloat = 0.9
        static let grillHeightRatio: CGFloat = 0.2
        static let grillFlameAreaHeightRatio: CGFloat = 0.9
        static let grillFlameAreaHeight: CGFloat = 20.0
        static let grillFlameCenterYOffset: CGFloat = -0.07
    }
    
    private struct Timing {
        static let gameOverDelay: TimeInterval = 1.0
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
    private var isSpeechEnabled = false
    
    // MARK: - Delegate
    weak var gameDelegate: GameSceneDelegate?

    // MARK: - Initialization
    override init(size: CGSize) {
        self.progressionManager = LearningProgressionManager(
            initialStage: UserSettings.shared.initialLearningStage
        )
        super.init(size: size)
        setupSpeechRecognition()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.progressionManager = LearningProgressionManager(
            initialStage: UserSettings.shared.initialLearningStage
        )
        super.init(coder: aDecoder)
        setupSpeechRecognition()
    }
    
    private func setupSpeechRecognition() {
        SpeechRecognitionManager.shared.delegate = self
        isSpeechEnabled = UserSettings.shared.isSpeechRecognitionEnabled
        print("🎮 setupSpeechRecognition() - isSpeechEnabled: \(isSpeechEnabled)")
    }

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = Visual.backgroundColor
        
        worldNode = SKNode()
        worldNode.name = "worldNode"
        addChild(worldNode)
        
        renderer = GameSceneRenderer(worldNode: worldNode, sceneSize: size, safeAreaInsets: safeAreaInsets)
        physics = GameScenePhysics(worldNode: worldNode, sceneSize: size, safeAreaInsets: safeAreaInsets)
        input = GameSceneInput(worldNode: worldNode)
        input.delegate = self
        input.updateVoiceInputState(isSpeechEnabled)
        
        physicsWorld.contactDelegate = self
        physics.setupPhysicsWorld(for: self)
        
        setupBarbecueGrill()
        
        renderer.setupUI()
        renderer.updateScore(scoreManager.score)
        renderer.updateProgress(progressionManager.progressText)
        
        PigTextureGenerator.shared.preloadCommonLetters()
        
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
        
        grillForeground = SKSpriteNode(texture: foregroundFrames.first)
        grillForeground.name = "grill"
        grillForeground.size = grillSize
        grillForeground.position = grillBackground.position
        grillForeground.zPosition = ZPosition.grillForeground
        
        worldNode.addChild(grillForeground)
        
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
        let preparationTime = UserSettings.shared.preparationTime
        let delayBetweenRounds = UserSettings.shared.delayBetweenRounds
        
        // When to start the morse code
        let morseStartDelay = delayBetweenRounds
        
        //MTM
        let seq = SKAction.sequence([
            .wait(forDuration: morseStartDelay),
            .run { MorseCodePlayer.shared.play(letters: roundLetters) },
            .wait(forDuration: morseDuration + preparationTime),
            .run { [weak self] in
                self?.spawnRoundPigs()
                self?.startSpeechRecognitionIfEnabled()
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
    
    private func startSpeechRecognitionIfEnabled() {
        print("🎮 startSpeechRecognitionIfEnabled() called")
        print("🎮 isSpeechEnabled: \(isSpeechEnabled)")
        print("🎮 isAuthorized: \(SpeechRecognitionManager.shared.isAuthorized)")
        
        guard isSpeechEnabled, SpeechRecognitionManager.shared.isAuthorized else {
            print("🎮 Speech recognition not starting - enabled: \(isSpeechEnabled), authorized: \(SpeechRecognitionManager.shared.isAuthorized)")
            return
        }
        
        do {
            try SpeechRecognitionManager.shared.startListening()
            print("🎮 Speech recognition started successfully from GameScene")
        } catch {
            print("🎮 Failed to start speech recognition: \(error)")
        }
    }
    
    private func stopSpeechRecognition() {
        SpeechRecognitionManager.shared.stopListening()
    }
    
    private func evaluateRound() {
        stopSpeechRecognition()
        
        progressionManager.updateStats(
            selectedLetters: roundManager.selectedOrder,
            correctLetters: roundManager.roundLetters
        )
        
        // Same logic for both voice and tap modes
        if roundManager.hadAnyCorrect {
            let result = scoreManager.calculateRoundScore(
                correctCount: roundManager.correctInSequence,
                totalCount: roundManager.roundLetters.count
            )
            renderer.updateScore(scoreManager.score, flashType: result.flashType)
        } else {
            scoreManager.resetStreak()
        }
        
        roundManager.endRound()
        
        renderer.updateFailureDisplay(count: roundManager.failedRoundsCount)
        
        if roundManager.isGameOver {
            endGame()
        } else {
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
        stopSpeechRecognition()
        
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
        renderer.hideGameOver()
        
        scoreManager.reset()
        progressionManager.reset(to: UserSettings.shared.initialLearningStage)
        roundManager.reset()
        input.reset()
        
        isGameOver = false
        nextRoundScheduled = false
        
        renderer.updateScore(scoreManager.score)
        renderer.updateProgress(progressionManager.progressText)
        renderer.updateFailureDisplay(count: 0)
        
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
        guard pigNode.parent != nil else { return }
        
        // Only burn pigs that are actually low on screen
        // If pig is in top 50% of screen, ignore the contact
        if pigNode.position.y > size.height * 0.5 {
            print("🐷 Ignoring high contact at y: \(pigNode.position.y)")
            return
        }
        
        pigNode.physicsBody = nil
        renderer.createSmokeEffect(at: pigNode.position)
        pigNode.removeFromParent()
    }
    
    // MARK: - GameSceneInputDelegate
    func didTapPig(letter: Character, sprite: SKSpriteNode) -> Bool {
        return handlePigSelection(letter: letter, sprite: sprite)
    }
    
    func didTapGrill() {
        stopSpeechRecognition()
        gameDelegate?.pauseGame()
    }
    
    // MARK: - SpeechRecognitionDelegate
    func didRecognizeLetter(_ letter: Character) {
        print("🎮 GameScene received letter: \(letter)")
        print("🎮 Round active: \(roundManager.isRoundActive)")
        
        guard roundManager.isRoundActive else {
            print("🎮 Ignoring letter - round not active")
            return
        }
        
        // Find the first pig with this letter
        let pigs = physics.getAllPigs(from: worldNode)
        print("🎮 Total pigs on screen: \(pigs.count)")
        
        for pig in pigs {
            if let letterString = pig.userData?["letter"] as? String,
               let pigLetter = letterString.first,
               pigLetter == letter,
               pig.userData?["isBeingRemoved"] as? Bool != true {
                print("🎮 Found matching pig with letter \(letter), attempting selection")
                
                // For voice input, handle selection without penalty logic
                let wasCorrect = roundManager.selectLetter(letter)
                
                if wasCorrect {
                    pig.physicsBody = nil
                    renderer.removePigWithAnimation(pig)
                    print("🎮 Selection was correct: \(wasCorrect)")
                } else {
                    // For voice input, incorrect selection is just ignored
                    print("🎮 Selection was incorrect - ignoring (voice input mode)")
                }
                break
            }
        }
    }
    
    func speechRecognitionAvailabilityChanged(_ isAvailable: Bool) {
        print("Speech recognition availability: \(isAvailable)")
    }
    
    // MARK: - Shared Selection Logic
    private func handlePigSelection(letter: Character, sprite: SKSpriteNode) -> Bool {
        guard roundManager.isRoundActive else { return false }
        
        let wasCorrect = roundManager.selectLetter(letter)
        
        if wasCorrect {
            sprite.physicsBody = nil
            renderer.removePigWithAnimation(sprite)
        }
        
        return wasCorrect
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
        physics.removeOffscreenPigs(from: worldNode)
        
        if !nextRoundScheduled && physics.getAllPigs(from: worldNode).isEmpty {
            evaluateRound()
        }
    }
    
    // MARK: - Helper Methods
//    private func calculateMorseDuration(for letters: [Character]) -> TimeInterval {
//        let dot = 0.1, dash = 0.3, intra = dot, inter = dot * 3
//        var duration: TimeInterval = 0
//        for (i, ch) in letters.enumerated() {
//            guard let code = MorseCodePlayer.shared.mapping[ch] else { continue }
//            for symbol in code {
//                duration += (symbol == "." ? dot : dash) + intra
//            }
//            if i < letters.count - 1 { duration += inter }
//        }
//        return duration
//    }
    
    // In GameScene.swift - calculateMorseDuration method
    private func calculateMorseDuration(for letters: [Character]) -> TimeInterval {
        let characterSpeed = UserSettings.shared.morseCharacterSpeed
        let farnsworthSpacing = UserSettings.shared.morseFarnsworthSpacing
        
        // Calculate timing (same formula as MorseCodePlayer)
        let dotDuration = 1.2 / characterSpeed
        let symbolGap = dotDuration
        let effectiveSpacing = min(farnsworthSpacing, characterSpeed)
        let stretchFactor = characterSpeed / effectiveSpacing
        let letterGap = dotDuration * 3 * stretchFactor
        
        var duration: TimeInterval = 0
        for (i, ch) in letters.enumerated() {
            guard let code = MorseCodePlayer.shared.mapping[ch] else { continue }
            for symbol in code {
                let elementDuration = symbol == "." ? dotDuration : (dotDuration * 3)
                duration += elementDuration + symbolGap
            }
            if i < letters.count - 1 {
                duration += letterGap
            }
        }
        return duration
    }
    
}
