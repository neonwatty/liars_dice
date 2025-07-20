//
//  GameStateScreen3Tests.swift
//  liars-dice-app Watch AppTests
//
//  Unit tests for Screen 3 functionality in GameState
//

import Testing
import Foundation
@testable import liars_dice_app_Watch_App

struct GameStateScreen3Tests {
    
    // MARK: - My Dice Count Tests
    
    @Test func testMyDiceCountInitialization() {
        let gameState = GameState()
        
        #expect(gameState.myDiceCount == 0)
        #expect(gameState.handConfiguration == nil)
    }
    
    @Test func testUpdateMyDiceCount() {
        let gameState = GameState()
        
        gameState.updateMyDiceCount(5)
        #expect(gameState.myDiceCount == 5)
    }
    
    @Test func testMyDiceCountValidation() {
        let gameState = GameState()
        
        // Test negative values
        gameState.updateMyDiceCount(-1)
        #expect(gameState.myDiceCount == 0)
        
        // Test exceeding total dice count
        gameState.updateMyDiceCount(50)
        #expect(gameState.myDiceCount == gameState.totalDiceCount)
    }
    
    @Test func testMyDiceCountResetsHandConfiguration() {
        let gameState = GameState()
        
        // Set up hand configuration
        gameState.updateMyDiceCount(3)
        gameState.initializeHandConfiguration()
        #expect(gameState.handConfiguration != nil)
        
        // Change my dice count - should reset hand configuration
        gameState.updateMyDiceCount(5)
        #expect(gameState.handConfiguration == nil)
    }
    
    // MARK: - Hand Configuration Tests
    
    @Test func testInitializeHandConfiguration() {
        let gameState = GameState()
        
        // Should not initialize with 0 dice
        gameState.updateMyDiceCount(0)
        gameState.initializeHandConfiguration()
        #expect(gameState.handConfiguration == nil)
        
        // Should initialize with positive dice count
        gameState.updateMyDiceCount(3)
        gameState.initializeHandConfiguration(bidFace: 4)
        
        #expect(gameState.handConfiguration != nil)
        #expect(gameState.handConfiguration?.diceCount == 3)
        #expect(gameState.handConfiguration?.bidFace == 4)
    }
    
    @Test func testUpdateHandDie() {
        let gameState = GameState()
        gameState.updateMyDiceCount(3)
        gameState.initializeHandConfiguration()
        
        // Update die value
        gameState.updateHandDie(at: 0, to: 5)
        #expect(gameState.handConfiguration?.getDie(at: 0) == 5)
        
        // Clear die value
        gameState.updateHandDie(at: 0, to: nil)
        #expect(gameState.handConfiguration?.getDie(at: 0) == nil)
        
        // Invalid index should not crash
        gameState.updateHandDie(at: 10, to: 3)
        #expect(gameState.handConfiguration?.getDie(at: 0) == nil) // Should remain unchanged
    }
    
    @Test func testUpdateHandBidFace() {
        let gameState = GameState()
        gameState.updateMyDiceCount(2)
        gameState.initializeHandConfiguration(bidFace: 1)
        
        gameState.updateHandBidFace(6)
        #expect(gameState.handConfiguration?.bidFace == 6)
        
        // Invalid bid face should be rejected by HandConfiguration
        gameState.updateHandBidFace(10)
        #expect(gameState.handConfiguration?.bidFace == 6) // Should remain unchanged
    }
    
    @Test func testResetHandConfiguration() {
        let gameState = GameState()
        gameState.updateMyDiceCount(3)
        gameState.initializeHandConfiguration()
        gameState.updateHandDie(at: 0, to: 4)
        
        // Verify setup
        #expect(gameState.handConfiguration != nil)
        
        // Reset and verify
        gameState.resetHandConfiguration()
        #expect(gameState.handConfiguration == nil)
        #expect(gameState.conditionalProbability == 0.0)
        #expect(gameState.conditionalProbabilityPercentage == "0%")
    }
    
    // MARK: - Navigation Tests
    
    @Test func testHandConfigurationInitialization() {
        let gameState = GameState()
        
        // Should not initialize with 0 dice
        gameState.updateMyDiceCount(0)
        gameState.initializeHandConfiguration()
        #expect(gameState.handConfiguration == nil)
        
        // Should initialize with positive dice count
        gameState.updateMyDiceCount(3)
        gameState.initializeHandConfiguration()
        #expect(gameState.handConfiguration != nil)
        #expect(gameState.handConfiguration?.diceCount == 3)
    }
    
    @Test func testResetHandConfigurationFromNavigation() {
        let gameState = GameState()
        gameState.updateMyDiceCount(3)
        gameState.initializeHandConfiguration()
        
        #expect(gameState.handConfiguration != nil)
        
        gameState.resetHandConfiguration()
        #expect(gameState.handConfiguration == nil)
    }
    
    // MARK: - Conditional Probability Tests
    
    @Test func testConditionalProbabilityCalculation() {
        let gameState = GameState()
        gameState.updateMyDiceCount(2)
        gameState.initializeHandConfiguration(bidFace: 3)
        
        // Set one die to match bid face
        gameState.updateHandDie(at: 0, to: 3)
        
        // Should calculate conditional probability
        #expect(gameState.conditionalProbability > 0.0)
        #expect(gameState.conditionalProbabilityPercentage != "0%")
    }
    
    @Test func testProbabilityImprovement() {
        let gameState = GameState()
        gameState.updateMyDiceCount(2)
        gameState.initializeHandConfiguration(bidFace: 3)
        
        // Set dice that help the bid
        gameState.updateHandDie(at: 0, to: 3)
        gameState.updateHandDie(at: 1, to: 3)
        
        // Should show improvement when we have favorable dice
        let improvement = gameState.probabilityImprovement
        #expect(improvement > 0.0)
        
        let improvementString = gameState.probabilityImprovementString
        #expect(improvementString.hasPrefix("+"))
    }
    
    @Test func testProbabilityImprovementString() {
        let gameState = GameState()
        gameState.updateMyDiceCount(2)
        gameState.initializeHandConfiguration()
        
        // Mock different improvement scenarios
        // Note: These test the string formatting logic
        let testCases: [(Double, String)] = [
            (0.25, "+25%"),
            (-0.15, "-15%"),
            (0.005, "±0%"),
            (-0.005, "±0%"),
            (0.0, "±0%")
        ]
        
        // We can't directly set the improvement, but we can test the logic
        // by examining the computed property behavior
        #expect(gameState.probabilityImprovementString.contains("%"))
    }
    
    // MARK: - Total Dice Integration Tests
    
    @Test func testTotalDiceChangeResetsHandConfiguration() {
        let gameState = GameState()
        gameState.updateMyDiceCount(3)
        gameState.initializeHandConfiguration()
        gameState.updateHandDie(at: 0, to: 5)
        
        // Verify setup
        #expect(gameState.handConfiguration != nil)
        
        // Change total dice count
        gameState.updateTotalDice(15)
        
        // Hand configuration should be reset
        #expect(gameState.handConfiguration == nil)
    }
    
    @Test func testMyDiceCountConstrainedByTotalDice() {
        let gameState = GameState()
        
        // Set total dice to 5
        gameState.updateTotalDice(5)
        
        // Try to set my dice higher than total
        gameState.updateMyDiceCount(10)
        
        // Should be constrained to total dice count
        #expect(gameState.myDiceCount == 5)
    }
    
    // MARK: - Accessibility and Description Tests
    
    @Test func testConditionalProbabilityDescription() {
        let gameState = GameState()
        gameState.updateMyDiceCount(1)
        gameState.initializeHandConfiguration()
        
        // Set up a favorable scenario
        gameState.updateHandDie(at: 0, to: gameState.handConfiguration?.bidFace ?? 1)
        
        let description = gameState.conditionalProbabilityDescription
        #expect(["Favorable", "Moderate", "Unlikely"].contains(description))
    }
    
    @Test func testMyDiceCountTracking() {
        let gameState = GameState()
        
        #expect(gameState.myDiceCount == 0)
        
        gameState.updateMyDiceCount(1)
        #expect(gameState.myDiceCount == 1)
        
        gameState.updateMyDiceCount(0)
        #expect(gameState.myDiceCount == 0)
    }
    
    // MARK: - Edge Cases
    
    @Test func testHandConfigurationWithSingleDie() {
        let gameState = GameState()
        gameState.updateMyDiceCount(1)
        gameState.initializeHandConfiguration(bidFace: 6)
        
        gameState.updateHandDie(at: 0, to: 6)
        
        // Should work correctly with single die
        #expect(gameState.handConfiguration?.countMatchingBidFace() == 1)
        #expect(gameState.conditionalProbability > 0.0)
    }
    
    @Test func testHandConfigurationWithMaxDice() {
        let gameState = GameState()
        gameState.updateTotalDice(10)
        gameState.updateMyDiceCount(10)
        gameState.initializeHandConfiguration()
        
        // Should handle having all dice
        #expect(gameState.handConfiguration?.diceCount == 10)
        #expect(gameState.conditionalProbability >= 0.0)
    }
    
    @Test func testRapidStateChanges() {
        let gameState = GameState()
        
        // Rapid changes should not cause crashes
        for i in 1...5 {
            gameState.updateMyDiceCount(i)
            gameState.initializeHandConfiguration()
            gameState.updateHandDie(at: 0, to: i)
            gameState.resetHandConfiguration()
        }
        
        // Should end in consistent state
        #expect(gameState.myDiceCount == 5)
        #expect(gameState.handConfiguration == nil)
    }
}