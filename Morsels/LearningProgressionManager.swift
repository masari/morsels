//
//  LearningProgressionManager.swift
//  Morsels
//
//  Created by Mark Messer on 10/4/25.
//


//
//  LearningProgressionManager.swift
//  Morsels
//
//  Manages letter progression and learning statistics
//

import Foundation

class LearningProgressionManager {
    
    // MARK: - Configuration
    private struct ProgressionRules {
        static let masteryThreshold = 5
        static let minAccuracyForAdvancement: Double = 0.8
    }
    
    // MARK: - Letter Progression
    private let letterProgression: [Character] = [
        "E", "T", "I", "A", "N", "M", "S", "U", "R", "W", "D", "K", "G",
        "O", "H", "V", "F", "L", "P", "J", "B", "X", "C", "Y", "Z", "Q"
    ]
    
    // MARK: - Properties
    private(set) var currentStage: Int
    private(set) var letterStats: [Character: (correct: Int, total: Int)] = [:]
    
    // MARK: - Computed Properties
    var availableLetters: [Character] {
        Array(letterProgression[0...currentStage])
    }
    
    var progressText: String {
        "Learning: \(currentStage + 1)/\(letterProgression.count) letters"
    }
    
    var currentStageLetter: Character {
        letterProgression[currentStage]
    }
    
    // MARK: - Initialization
    init(initialStage: Int = 2) {
        self.currentStage = min(initialStage, letterProgression.count - 1)
        initializeStats()
    }
    
    private func initializeStats() {
        letterStats.removeAll()
        for i in 0...currentStage {
            letterStats[letterProgression[i]] = (correct: 0, total: 0)
        }
    }
    
    // MARK: - Round Generation
    
    /// Generates a random selection of letters for a round
    /// - Parameters:
    ///   - minLength: Minimum number of letters
    ///   - maxLength: Maximum number of letters
    ///   - allowDuplicates: Whether to allow duplicate letters
    /// - Returns: Array of letters for the round
    func generateRoundLetters(minLength: Int = 1, maxLength: Int = 4, allowDuplicates: Bool = false) -> [Character] {
        let count = Int.random(in: minLength...min(maxLength, availableLetters.count))
        
        if allowDuplicates {
            return (0..<count).compactMap { _ in availableLetters.randomElement() }
        } else {
            var shuffled = availableLetters
            shuffled.shuffle()
            return Array(shuffled.prefix(count))
        }
    }
    
    // MARK: - Statistics Tracking
    
    /// Updates statistics based on round performance
    /// - Parameters:
    ///   - selectedLetters: Letters the player selected
    ///   - correctLetters: The correct sequence of letters
    func updateStats(selectedLetters: [Character], correctLetters: [Character]) {
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
    
    // MARK: - Progression
    
    /// Checks if player is ready to advance to the next stage
    /// - Returns: True if advancement occurred
    func checkForAdvancement() -> Bool {
        guard currentStage < letterProgression.count - 1 else { return false }
        
        let currentStageLetters = letterProgression[0...currentStage]
        let canAdvance = currentStageLetters.allSatisfy { letter in
            guard let stats = letterStats[letter] else { return false }
            let accuracy = stats.total > 0 ? Double(stats.correct) / Double(stats.total) : 0.0
            return stats.correct >= ProgressionRules.masteryThreshold && 
                   accuracy >= ProgressionRules.minAccuracyForAdvancement
        }
        
        if canAdvance {
            currentStage += 1
            let newLetter = letterProgression[currentStage]
            letterStats[newLetter] = (correct: 0, total: 0)
            return true
        }
        
        return false
    }
    
    // MARK: - Reset
    
    /// Resets progression to a specific stage
    func reset(to stage: Int = 2) {
        currentStage = min(stage, letterProgression.count - 1)
        initializeStats()
    }
}