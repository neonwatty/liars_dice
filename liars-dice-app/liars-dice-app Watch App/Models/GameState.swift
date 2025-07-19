//
//  GameState.swift
//  liars-dice-app Watch App
//
//  Observable model that manages the current game state
//

import Foundation
import SwiftUI

class GameState: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var totalDiceCount: Int = 10 {
        didSet {
            // Ensure bid doesn't exceed new dice count
            if currentBid > totalDiceCount {
                currentBid = totalDiceCount
            }
            updateProbability()
        }
    }
    
    @Published private(set) var currentBid: Int = 2 {
        didSet {
            updateProbability()
        }
    }
    
    @Published private(set) var currentProbability: Double = 0.0
    @Published private(set) var probabilityPercentage: String = "0%"
    @Published private(set) var probabilityColor: Color = .red
    @Published private(set) var breakEvenBid: Int = 0
    
    // MARK: - Private Properties
    
    private let probabilityEngine = ProbabilityEngine.shared
    private let minDice = 1
    private let maxDice = 40
    
    // MARK: - Initialization
    
    init() {
        updateProbability()
    }
    
    // MARK: - Public Methods
    
    /// Update the total dice count with validation
    func updateTotalDice(_ newCount: Int) {
        let validatedCount = max(minDice, min(maxDice, newCount))
        if validatedCount != totalDiceCount {
            totalDiceCount = validatedCount
        }
    }
    
    /// Update the current bid with validation
    func updateCurrentBid(_ newBid: Int) {
        let validatedBid = max(0, min(totalDiceCount, newBid))
        if validatedBid != currentBid {
            currentBid = validatedBid
        }
    }
    
    /// Increment total dice count by 1
    func incrementDice() {
        updateTotalDice(totalDiceCount + 1)
    }
    
    /// Decrement total dice count by 1
    func decrementDice() {
        updateTotalDice(totalDiceCount - 1)
    }
    
    /// Increment current bid by 1
    func incrementBid() {
        updateCurrentBid(currentBid + 1)
    }
    
    /// Decrement current bid by 1
    func decrementBid() {
        updateCurrentBid(currentBid - 1)
    }
    
    // MARK: - Private Methods
    
    private func updateProbability() {
        let oldProbability = currentProbability
        
        // Update probability value
        currentProbability = probabilityEngine.getProbability(
            bid: currentBid,
            totalDice: totalDiceCount
        )
        
        // Update percentage string
        probabilityPercentage = probabilityEngine.getProbabilityPercentage(
            bid: currentBid,
            totalDice: totalDiceCount
        )
        
        // Update color
        probabilityColor = probabilityEngine.getColorForBid(
            bid: currentBid,
            totalDice: totalDiceCount
        )
        
        // Update break-even bid
        breakEvenBid = probabilityEngine.getBreakEvenBid(
            totalDice: totalDiceCount
        )
        
        // Announce significant probability changes for VoiceOver users
        announceSignificantChanges(oldProbability: oldProbability)
    }
    
    /// Announce significant probability changes for accessibility
    private func announceSignificantChanges(oldProbability: Double) {
        let oldCategory = getProbabilityCategory(oldProbability)
        let newCategory = getProbabilityCategory(currentProbability)
        
        if oldCategory != newCategory {
            let announcement = "Probability changed to \(probabilityPercentage), \(probabilityDescription)"
            
            #if os(iOS)
            // Post accessibility announcement for iOS
            DispatchQueue.main.async {
                UIAccessibility.post(notification: .announcement, argument: announcement)
            }
            #elseif os(watchOS)
            // For watchOS, we rely on VoiceOver reading the updated accessibility values
            // The accessibilityValue on the probability display will be read automatically
            print("Accessibility: \(announcement)")
            #endif
        }
    }
    
    /// Get probability category for change detection
    private func getProbabilityCategory(_ probability: Double) -> String {
        if probability >= 0.5 {
            return "favorable"
        } else if probability >= 0.3 {
            return "moderate"
        } else {
            return "unlikely"
        }
    }
    
    // MARK: - Computed Properties
    
    /// Check if current bid is at or above break-even threshold
    var isAboveBreakEven: Bool {
        return currentBid <= breakEvenBid
    }
    
    /// Get descriptive text for probability level
    var probabilityDescription: String {
        if currentProbability >= 0.5 {
            return "Favorable"
        } else if currentProbability >= 0.3 {
            return "Moderate"
        } else {
            return "Unlikely"
        }
    }
}