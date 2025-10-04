//
//  RoundManager.swift
//  Morsels
//
//  Created by Mark Messer on 10/4/25.
//


//
//  RoundManager.swift
//  Morsels
//
//  Manages round state and failure tracking
//

import Foundation

class RoundManager {
    
    // MARK: - Configuration
    private struct RoundRules {
        static let maxFailedRounds = 3
    }
    
    // MARK: - Round State
    private(set) var roundLetters: [Character] = []
    private(set) var selectedOrder: [Character] = []
    private(set) var isRoundActive = false
    
    // MARK: - Failure Tracking
    private(set) var failedRoundsCount = 0
    
    // MARK: - Computed Properties
    
    var isGameOver: Bool {
        failedRoundsCount >= RoundRules.maxFailedRounds
    }
    
    var correctInSequence: Int {
        var count = 0
        for i in 0..<min(selectedOrder.count, roundLetters.count) {
            if selectedOrder[i] == roundLetters[i] {
                count += 1
            } else {
                break
            }
        }
        return count
    }
    
    var isRoundComplete: Bool {
        selectedOrder.count == roundLetters.count && correctInSequence == roundLetters.count
    }
    
    var hadAnyCorrect: Bool {
        correctInSequence > 0
    }
    
    // MARK: - Round Management
    
    /// Starts a new round with the given letters
    func startRound(with letters: [Character]) {
        roundLetters = letters
        selectedOrder.removeAll()
        isRoundActive = true
    }
    
    /// Records a letter selection
    /// - Parameter letter: The letter that was selected
    /// - Returns: True if the selection was correct for the current position
    func selectLetter(_ letter: Character) -> Bool {
        guard isRoundActive, selectedOrder.count < roundLetters.count else {
            return false
        }
        
        let expectedLetter = roundLetters[selectedOrder.count]
        selectedOrder.append(letter)
        
        return letter == expectedLetter
    }
    
    /// Ends the current round and updates failure count
    func endRound() {
        isRoundActive = false
        
        if hadAnyCorrect {
            failedRoundsCount = 0
        } else {
            failedRoundsCount += 1
        }
    }
    
    /// Resets all round state
    func reset() {
        roundLetters.removeAll()
        selectedOrder.removeAll()
        isRoundActive = false
        failedRoundsCount = 0
    }
    
    // MARK: - Helper Methods
    
    /// Gets the next expected letter (for hints/debugging)
    var nextExpectedLetter: Character? {
        guard selectedOrder.count < roundLetters.count else { return nil }
        return roundLetters[selectedOrder.count]
    }
}
