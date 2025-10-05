//
//  GameSceneRenderer.swift (Updated with Speech Indicator)
//  Morsels
//

import SpriteKit

class GameSceneRenderer {
    
    // MARK: - Configuration
    private struct Layout {
        static let scoreLabelRightMargin: CGFloat = 20.0
        static let scoreLabelTopMargin: CGFloat = 20.0
        static let progressLabelLeftMargin: CGFloat = 20.0
        static let progressLabelTopMargin: CGFloat = 20.0
        static let failureIndicatorSpacing: CGFloat = 5.0
        static let failureIndicatorBottomOffset: CGFloat = 20.0
        static let speechIndicatorBottomMargin: CGFloat = 20.0
        static let speechIndicatorSize: CGFloat = 40.0
    }
    
    private struct Visual {
        static let scoreLabelFontName = "Helvetica-Bold"
        static let scoreLabelFontSize: CGFloat = 24
        static let scoreLabelFontColor: UIColor = .black
        
        static let progressLabelFontName = "Helvetica"
        static let progressLabelFontSize: CGFloat = 16
        static let progressLabelFontColor: UIColor = .darkGray
        
        static let failureIndicatorFontSize: CGFloat = 30
        
        static let scoreFlashColorStreak: UIColor = .purple
        static let scoreFlashColorPerfect: UIColor = .green
        static let scoreFlashColorPartial: UIColor = .orange
        static let scoreLabelFlashDuration: TimeInterval = 0.5
        
        static let progressFlashColor: UIColor = .green
        static let progressLabelFlashDuration: TimeInterval = 1.0
        
        static let pigRemovalScaleFactor: CGFloat = 0.1
        static let pigRemovalDuration: TimeInterval = 0.3
        
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
        
        static let gameOverOverlayFadeDuration: TimeInterval = 0.5
        
        static let speechIndicatorActiveColor: UIColor = .systemGreen
        static let speechIndicatorInactiveColor: UIColor = .systemGray
    }
    
    private struct ZPosition {
        static let pigs: CGFloat = 0
        static let speechIndicator: CGFloat = 5
        static let gameOverOverlay: CGFloat = 10
        static let gameOverLabels: CGFloat = 11
    }
    
    // MARK: - Properties
    private weak var worldNode: SKNode?
    private let sceneSize: CGSize
    private var safeAreaInsets: UIEdgeInsets
    
    private var scoreLabel: SKLabelNode!
    private var progressLabel: SKLabelNode!
    private var failureIndicatorNodes: [SKLabelNode] = []
    private var speechIndicator: SKLabelNode?
    
    // MARK: - Initialization
    init(worldNode: SKNode, sceneSize: CGSize, safeAreaInsets: UIEdgeInsets) {
        self.worldNode = worldNode
        self.sceneSize = sceneSize
        self.safeAreaInsets = safeAreaInsets
    }
    
    // MARK: - Setup
    func setupUI() {
        guard let worldNode = worldNode else { return }
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = Visual.scoreLabelFontName
        scoreLabel.fontSize = Visual.scoreLabelFontSize
        scoreLabel.fontColor = Visual.scoreLabelFontColor
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .top
        updateScoreLabelPosition()
        worldNode.addChild(scoreLabel)
        
        progressLabel = SKLabelNode(text: "")
        progressLabel.fontName = Visual.progressLabelFontName
        progressLabel.fontSize = Visual.progressLabelFontSize
        progressLabel.fontColor = Visual.progressLabelFontColor
        progressLabel.horizontalAlignmentMode = .left
        progressLabel.verticalAlignmentMode = .top
        updateProgressLabelPosition()
        worldNode.addChild(progressLabel)
        
        // Speech indicator (microphone emoji)
        speechIndicator = SKLabelNode(text: "🎤")
        speechIndicator?.fontSize = Layout.speechIndicatorSize
        speechIndicator?.zPosition = ZPosition.speechIndicator
        speechIndicator?.alpha = 0 // Hidden by default
        updateSpeechIndicatorPosition()
        worldNode.addChild(speechIndicator!)
    }
    
    func updateSafeAreaInsets(_ insets: UIEdgeInsets) {
        self.safeAreaInsets = insets
        updateScoreLabelPosition()
        updateProgressLabelPosition()
        updateSpeechIndicatorPosition()
        updateFailureDisplay(count: failureIndicatorNodes.count)
    }
    
    private func updateScoreLabelPosition() {
        scoreLabel?.position = CGPoint(
            x: sceneSize.width - Layout.scoreLabelRightMargin - safeAreaInsets.right,
            y: sceneSize.height - Layout.scoreLabelTopMargin - safeAreaInsets.top
        )
    }
    
    private func updateProgressLabelPosition() {
        progressLabel?.position = CGPoint(
            x: Layout.progressLabelLeftMargin + safeAreaInsets.left,
            y: sceneSize.height - Layout.progressLabelTopMargin - safeAreaInsets.top
        )
    }
    
    private func updateSpeechIndicatorPosition() {
        speechIndicator?.position = CGPoint(
            x: sceneSize.width / 2,
            y: Layout.speechIndicatorBottomMargin + safeAreaInsets.bottom
        )
    }
    
    // MARK: - Score Display
    func updateScore(_ score: Int, flashType: ScoreFlashType? = nil) {
        scoreLabel.text = "Score: \(score)"
        
        if let flashType = flashType {
            let flashColor = colorForFlashType(flashType)
            let flashAction = SKAction.sequence([
                .run { self.scoreLabel.fontColor = flashColor },
                .wait(forDuration: Visual.scoreLabelFlashDuration),
                .run { self.scoreLabel.fontColor = Visual.scoreLabelFontColor }
            ])
            scoreLabel.run(flashAction)
        }
    }
    
    private func colorForFlashType(_ type: ScoreFlashType) -> UIColor {
        switch type {
        case .streak: return Visual.scoreFlashColorStreak
        case .perfect: return Visual.scoreFlashColorPerfect
        case .partial: return Visual.scoreFlashColorPartial
        }
    }
    
    // MARK: - Progress Display
    func updateProgress(_ text: String, didAdvance: Bool = false) {
        progressLabel.text = text
        
        if didAdvance {
            let celebrateAction = SKAction.sequence([
                .run { self.progressLabel.fontColor = Visual.progressFlashColor },
                .wait(forDuration: Visual.progressLabelFlashDuration),
                .run { self.progressLabel.fontColor = Visual.progressLabelFontColor }
            ])
            progressLabel.run(celebrateAction)
        }
    }
    
    // MARK: - Speech Indicator
    func updateSpeechIndicator(_ isListening: Bool) {
        guard let indicator = speechIndicator else { return }
        
        if isListening {
            indicator.alpha = 1.0
            indicator.fontColor = Visual.speechIndicatorActiveColor
            
            // Pulse animation
            let pulse = SKAction.sequence([
                .scale(to: 1.2, duration: 0.5),
                .scale(to: 1.0, duration: 0.5)
            ])
            indicator.run(SKAction.repeatForever(pulse), withKey: "pulse")
        } else {
            indicator.removeAction(forKey: "pulse")
            indicator.alpha = 0
            indicator.setScale(1.0)
        }
    }
    
    // MARK: - Failure Indicators
    func updateFailureDisplay(count: Int) {
        guard let worldNode = worldNode else { return }
        
        failureIndicatorNodes.forEach { $0.removeFromParent() }
        failureIndicatorNodes.removeAll()
        
        guard count > 0 else { return }
        
        let hamTemplate = SKLabelNode(text: "🍖")
        hamTemplate.fontSize = Visual.failureIndicatorFontSize
        let hamWidth = hamTemplate.frame.width
        let totalPossibleWidth = (CGFloat(3) * hamWidth) + (CGFloat(2) * Layout.failureIndicatorSpacing)
        let startX = (sceneSize.width - Layout.scoreLabelRightMargin - safeAreaInsets.right) - totalPossibleWidth
        
        for i in 0..<count {
            let hamLabel = SKLabelNode(text: "🍖")
            hamLabel.fontSize = Visual.failureIndicatorFontSize
            let xPos = startX + (hamWidth / 2) + (CGFloat(i) * (hamWidth + Layout.failureIndicatorSpacing))
            let yPos = scoreLabel.position.y - scoreLabel.frame.height - Layout.failureIndicatorBottomOffset
            hamLabel.position = CGPoint(x: xPos, y: yPos)
            worldNode.addChild(hamLabel)
            failureIndicatorNodes.append(hamLabel)
        }
    }
    
    // MARK: - Pig Removal Animation
    func removePigWithAnimation(_ pigSprite: SKSpriteNode) {
        let disappearAction = SKAction.group([
            .scale(to: Visual.pigRemovalScaleFactor, duration: Visual.pigRemovalDuration),
            .fadeOut(withDuration: Visual.pigRemovalDuration)
        ])
        pigSprite.run(SKAction.sequence([disappearAction, .removeFromParent()]))
    }
    
    // MARK: - Smoke Effect
    func createSmokeEffect(at position: CGPoint) {
        guard let worldNode = worldNode else { return }
        
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
            .wait(forDuration: 2.5),
            .removeFromParent()
        ])
        smokeEmitter.run(removeAction)
    }
    
    // MARK: - Game Over Display
    func showGameOver(finalScore: Int) {
        guard let worldNode = worldNode else { return }
        
        let overlay = SKShapeNode(rectOf: sceneSize)
        overlay.fillColor = .black
        overlay.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        overlay.zPosition = ZPosition.gameOverOverlay
        overlay.name = "gameOverOverlay"
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = Visual.gameOverLabelFontName
        gameOverLabel.fontSize = Visual.gameOverLabelFontSize
        gameOverLabel.fontColor = Visual.gameOverLabelFontColor
        gameOverLabel.position = CGPoint(x: 0, y: sceneSize.height * Visual.gameOverLabelYOffset)
        gameOverLabel.zPosition = ZPosition.gameOverLabels
        gameOverLabel.name = "gameOverLabel"
        
        let finalScoreLabel = SKLabelNode(text: "Final Score: \(finalScore)")
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
        restartLabel.position = CGPoint(x: 0, y: -sceneSize.height * Visual.restartLabelYOffset)
        restartLabel.zPosition = ZPosition.gameOverLabels
        restartLabel.name = "gameOverLabel"
        
        overlay.addChild(gameOverLabel)
        overlay.addChild(finalScoreLabel)
        overlay.addChild(restartLabel)
        worldNode.addChild(overlay)
        
        overlay.alpha = 0
        overlay.run(SKAction.fadeAlpha(to: Visual.gameOverOverlayAlpha, duration: Visual.gameOverOverlayFadeDuration))
    }
    
    func hideGameOver() {
        guard let worldNode = worldNode else { return }
        worldNode.children.filter { $0.name?.starts(with: "gameOver") ?? false }.forEach { $0.removeFromParent() }
    }
}
