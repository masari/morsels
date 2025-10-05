//
//  GameSceneInput.swift
//  Morsels
//
//  Handles touch input and pig selection
//

import SpriteKit

protocol GameSceneInputDelegate: AnyObject {
    func didTapPig(letter: Character, sprite: SKSpriteNode) -> Bool
    func didTapGrill()
}

class GameSceneInput {
    
    // MARK: - Configuration
    private struct Timing {
        static let penaltyDuration: TimeInterval = 1.0
        static let penaltyFlashInDuration: TimeInterval = 0.1
        static let penaltyFlashOutDuration: TimeInterval = 0.2
    }
    
    private struct Visual {
        static let penaltyFlashColor: UIColor = .systemBlue
        static let penaltyFlashBlendFactor: CGFloat = 0.9
    }
    
    // MARK: - Properties
    weak var delegate: GameSceneInputDelegate?
    private weak var worldNode: SKNode?
    private(set) var isPenaltyActive = false
    
    // MARK: - Initialization
    init(worldNode: SKNode) {
        self.worldNode = worldNode
    }
    
    // MARK: - Touch Handling
    func handleTouches(_ touches: Set<UITouch>) -> Bool {
        guard !isPenaltyActive, let worldNode = worldNode else { return false }
        
        var didHandleTouch = false
        
        for touch in touches {
            let location = touch.location(in: worldNode)
            
            // Check for grill tap first
            let touchedNode = worldNode.atPoint(location)
            if touchedNode.name == "grill" {
                delegate?.didTapGrill()
                return true
            }
            
            // Check for pig taps
            let ballNodes = worldNode.nodes(at: location).filter { $0.name == "ball" }
            
            for pigNode in ballNodes {
                guard let pigSprite = pigNode as? SKSpriteNode,
                      let letterString = pigSprite.userData?["letter"] as? String,
                      let tappedLetter = letterString.first,
                      pigSprite.userData?["isBeingRemoved"] as? Bool != true
                else { continue }
                
                // Mark as being removed to prevent double-tap
                pigSprite.userData?["isBeingRemoved"] = true
                
                // Ask delegate if this was correct
                let wasCorrect = delegate?.didTapPig(letter: tappedLetter, sprite: pigSprite) ?? false
                
                if !wasCorrect {
                    // Incorrect tap - unmark it so penalty can handle it
                    pigSprite.userData?["isBeingRemoved"] = false
                    triggerPenalty()
                    return true
                }
                
                didHandleTouch = true
            }
        }
        
        return didHandleTouch
    }
    
    // MARK: - Penalty System
    func triggerPenalty() {
        guard let worldNode = worldNode else { return }
        
        isPenaltyActive = true
        
        // Clear any "isBeingRemoved" flags from all pigs
        worldNode.children.filter { $0.name == "ball" }.forEach { node in
            if let sprite = node as? SKSpriteNode {
                sprite.userData?["isBeingRemoved"] = false
            }
        }
        
        // Get penalty duration from settings
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
        
        // Flash all pigs blue
        worldNode.children.filter { $0.name == "ball" }.forEach {
            $0.run(SKAction.sequence([turnBlue, wait, restoreColor]))
        }
        
        // End penalty after duration
        let endPenalty = SKAction.sequence([
            .wait(forDuration: penaltyDuration + Timing.penaltyFlashOutDuration),
            .run { [weak self] in self?.isPenaltyActive = false }
        ])
        worldNode.run(endPenalty)
    }
    
    // MARK: - State Management
    func reset() {
        isPenaltyActive = false
    }
}
