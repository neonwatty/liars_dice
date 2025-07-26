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
            resetHandConfigurationIfNeeded(oldValue)
            updateProbability()
        }
    }
    
    @Published private(set) var currentBid: Int = 2 {
        didSet {
            updateProbability()
        }
    }
    
    @Published private(set) var currentBidFace: Int = 1 {
        didSet {
            syncHandConfigurationBidFace()
            updateProbability()
            updateSpecificFaceProbability()
            updateConditionalProbability()
        }
    }
    
    @Published private(set) var currentProbability: Double = 0.0
    @Published private(set) var probabilityPercentage: String = "0%"
    @Published private(set) var probabilityColor: Color = .red
    @Published private(set) var breakEvenBid: Int = 0
    
    // MARK: - Screen 3 Properties
    
    @Published var myDiceCount: Int = 0 {
        didSet {
            if myDiceCount != oldValue {
                // Only reset if count actually changed and we're decreasing
                // When increasing, we keep the existing configuration and just resize
                if myDiceCount < oldValue || myDiceCount == 0 {
                    resetHandConfiguration()
                } else if myDiceCount > oldValue && handConfiguration != nil {
                    // Resize the existing configuration to preserve dice values
                    print("GameState: myDiceCount increased from \(oldValue) to \(myDiceCount), resizing hand configuration")
                    if var config = handConfiguration {
                        // Create a new configuration with the new size, preserving existing values
                        var newConfig = HandConfiguration(diceCount: myDiceCount, bidFace: config.bidFace)
                        // Copy existing dice values
                        for i in 0..<min(oldValue, myDiceCount) {
                            if let value = config.getDie(at: i) {
                                _ = newConfig.setDie(at: i, to: value)
                            }
                        }
                        handConfiguration = newConfig
                    }
                }
            }
        }
    }
    
    @Published var handConfiguration: HandConfiguration? = nil
    @Published var conditionalProbability: Double = 0.0
    @Published var conditionalProbabilityPercentage: String = "0%"
    @Published var conditionalProbabilityColor: Color = .red
    
    // Specific face probability for Screen 3 "Original" display
    @Published var specificFaceProbability: Double = 0.0
    @Published var specificFaceProbabilityPercentage: String = "0%"
    @Published var specificFaceProbabilityColor: Color = .red
    
    // MARK: - Private Properties
    
    private let probabilityEngine = ProbabilityEngine.shared
    private let conditionalProbabilityEngine = ConditionalProbabilityEngine.shared
    private let specificFaceProbabilityEngine = SpecificFaceProbabilityEngine.shared
    private let minDice = 1
    private let maxDice = 40
    
    // MARK: - Initialization
    
    init() {
        updateProbability()
        updateSpecificFaceProbability()
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
    
    /// Update the current bid face with validation
    func updateCurrentBidFace(_ newFace: Int) {
        let validatedFace = max(1, min(6, newFace))
        if validatedFace != currentBidFace {
            currentBidFace = validatedFace
        }
    }
    
    // MARK: - Screen 3 Methods
    
    /// Update my dice count with validation
    func updateMyDiceCount(_ newCount: Int) {
        let validatedCount = max(0, min(totalDiceCount, newCount))
        if validatedCount != myDiceCount {
            myDiceCount = validatedCount
        }
    }
    
    /// Initialize hand configuration for Screen 3
    func initializeHandConfiguration() {
        print("GameState: initializeHandConfiguration called - myDiceCount: \(myDiceCount), totalDiceCount: \(totalDiceCount)")
        guard myDiceCount > 0 else {
            print("GameState: myDiceCount is 0, setting handConfiguration to nil")
            handConfiguration = nil
            return
        }
        
        print("GameState: Creating HandConfiguration with \(myDiceCount) dice and bidFace \(currentBidFace)")
        handConfiguration = HandConfiguration(diceCount: myDiceCount, bidFace: currentBidFace)
        print("GameState: HandConfiguration created successfully")
        updateSpecificFaceProbability()
        updateConditionalProbability()
    }
    
    /// Update a specific die in the hand configuration
    func updateHandDie(at index: Int, to value: Int?) {
        print("GameState: updateHandDie called - index: \(index), value: \(String(describing: value))")
        guard var config = handConfiguration else { 
            print("GameState: ERROR - No hand configuration exists!")
            return 
        }
        
        print("GameState: Before update - die \(index) value: \(String(describing: config.getDie(at: index)))")
        
        if config.setDie(at: index, to: value) {
            print("GameState: setDie returned true")
            handConfiguration = config
            updateConditionalProbability()
            
            // Verify the update
            if let newConfig = handConfiguration {
                print("GameState: After update - die \(index) value: \(String(describing: newConfig.getDie(at: index)))")
            }
        } else {
            print("GameState: ERROR - setDie returned false!")
        }
    }
    
    /// Sync hand configuration bid face with current bid face
    private func syncHandConfigurationBidFace() {
        guard var config = handConfiguration else { return }
        
        if config.bidFace != currentBidFace {
            config.bidFace = currentBidFace
            handConfiguration = config
        }
    }
    
    /// Reset hand configuration
    func resetHandConfiguration() {
        handConfiguration = nil
        conditionalProbability = 0.0
        conditionalProbabilityPercentage = "0%"
        conditionalProbabilityColor = .red
        specificFaceProbability = 0.0
        specificFaceProbabilityPercentage = "0%"
        specificFaceProbabilityColor = .red
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
        
        // Also update specific face probability when bid changes
        updateSpecificFaceProbability()
    }
    
    /// Update conditional probability for Screen 3
    private func updateConditionalProbability() {
        guard let config = handConfiguration else {
            conditionalProbability = 0.0
            conditionalProbabilityPercentage = "0%"
            conditionalProbabilityColor = .red
            return
        }
        
        // Calculate conditional probability
        conditionalProbability = conditionalProbabilityEngine.getConditionalProbability(
            bid: currentBid,
            totalDice: totalDiceCount,
            handConfig: config
        )
        
        // Update percentage string
        conditionalProbabilityPercentage = conditionalProbabilityEngine.getConditionalProbabilityPercentage(
            bid: currentBid,
            totalDice: totalDiceCount,
            handConfig: config
        )
        
        // Update color
        conditionalProbabilityColor = conditionalProbabilityEngine.getConditionalProbabilityColor(
            bid: currentBid,
            totalDice: totalDiceCount,
            handConfig: config
        )
    }
    
    /// Reset hand configuration if total dice changed significantly
    private func resetHandConfigurationIfNeeded(_ oldTotalDice: Int) {
        // If total dice count changed, we should reset the hand configuration
        // since the game context has changed
        if totalDiceCount != oldTotalDice && handConfiguration != nil {
            resetHandConfiguration()
        }
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
    
    // MARK: - Screen 3 Computed Properties
    
    /// Update specific face probability for Screen 3
    private func updateSpecificFaceProbability() {
        // Calculate probability for specific face (not ANY face)
        specificFaceProbability = specificFaceProbabilityEngine.getProbability(
            bid: currentBid,
            totalDice: totalDiceCount
        )
        
        // Update percentage string
        specificFaceProbabilityPercentage = specificFaceProbabilityEngine.getProbabilityPercentage(
            bid: currentBid,
            totalDice: totalDiceCount
        )
        
        // Update color
        specificFaceProbabilityColor = specificFaceProbabilityEngine.getProbabilityColor(
            bid: currentBid,
            totalDice: totalDiceCount
        )
    }
    
    /// Get probability improvement from conditional calculation
    var probabilityImprovement: Double {
        guard let config = handConfiguration else { return 0.0 }
        
        return conditionalProbabilityEngine.getProbabilityImprovement(
            bid: currentBid,
            totalDice: totalDiceCount,
            handConfig: config,
            originalProbability: specificFaceProbability  // Use specific face probability as baseline
        )
    }
    
    /// Get formatted probability improvement string
    var probabilityImprovementString: String {
        let improvement = probabilityImprovement
        let percentage = Int(round(abs(improvement) * 100))
        
        if improvement > 0.01 {
            return "+\(percentage)%"
        } else if improvement < -0.01 {
            return "-\(percentage)%"
        } else {
            return "±0%"
        }
    }
    
    /// Get descriptive text for conditional probability level
    var conditionalProbabilityDescription: String {
        if conditionalProbability >= 0.5 {
            return "Favorable"
        } else if conditionalProbability >= 0.3 {
            return "Moderate"
        } else {
            return "Unlikely"
        }
    }
}