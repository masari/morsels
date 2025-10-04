//
//  ScoreManager.swift
//  Morsels
//
//  Created by Mark Messer on 10/4/25.
//


//
//  ScoreManager.swift
//  Morsels
//
//  Handles all scoring logic and streak tracking
//

import Foundation

class ScoreManager {
    
    // MARK: - Configuration
    private struct ScoringRules {
        static let pointsPerCorrectLetter = 10
        static let completionBonusPerBall = 50
        static let minBallsForBonus = 3
        static let streakBonusPoints = 25
        static let streakBonusInterval = 3
    }
    
    // MARK: - Properties
    private(set) var score: Int = 0
    private(set) var perfectRoundStreak: Int = 0
    
    // MARK: - Score Calculation
    
    /// Calculates points for a round and updates internal state
    /// - Parameters:
    ///   - correctCount: Number of correct selections in sequence
    ///   - totalCount: Total number of items in the round
    /// - Returns: Tuple containing (totalPoints, isComplete, streakBonus, flashColor)
    func calculateRoundScore(correctCount: Int, totalCount: Int) -> (points: Int, isComplete: Bool, streakBonus: Int, flashType: ScoreFlashType) {
        let sequencePoints = correctCount * ScoringRules.pointsPerCorrectLetter
        var totalPointsEarned = sequencePoints
        var isComplete = false
        var streakBonus = 0
        
        if correctCount == totalCount {
            isComplete = true
            perfectRoundStreak += 1
            
            // Completion bonus
            if totalCount >= ScoringRules.minBallsForBonus {
                totalPointsEarned += ScoringRules.completionBonusPerBall * totalCount
            }
            
            // Streak bonus
            if perfectRoundStreak > 0 && perfectRoundStreak % ScoringRules.streakBonusInterval == 0 {
                streakBonus = ScoringRules.streakBonusPoints * perfectRoundStreak
                totalPointsEarned += streakBonus
            }
        } else {
            perfectRoundStreak = 0
        }
        
        score += totalPointsEarned
        
        let flashType: ScoreFlashType = streakBonus > 0 ? .streak : (isComplete ? .perfect : .partial)
        
        return (totalPointsEarned, isComplete, streakBonus, flashType)
    }
    
    /// Resets the perfect round streak (called on penalty)
    func resetStreak() {
        perfectRoundStreak = 0
    }
    
    /// Resets all scoring state
    func reset() {
        score = 0
        perfectRoundStreak = 0
    }
}

// MARK: - Supporting Types

enum ScoreFlashType {
    case streak   // Purple flash for streak bonus
    case perfect  // Green flash for perfect round
    case partial  // Orange flash for partial completion
}