//
//  GameStateTests.swift
//  liars-dice-app Watch AppTests
//
//  Unit tests for the GameState class
//

import Testing
import Foundation
import SwiftUI
@testable import liars_dice_app_Watch_App

struct GameStateTests {
    
    // MARK: - Initialization Tests
    
    @Test func testInitialization() {
        let gameState = GameState()
        
        // Check default values
        #expect(gameState.totalDiceCount == 10, "Default dice count should be 10")
        #expect(gameState.currentBid == 2, "Default bid should be 2")
        #expect(gameState.breakEvenBid > 0, "Break-even should be calculated")
        #expect(!gameState.probabilityPercentage.isEmpty, "Probability percentage should be set")
    }
    
    // MARK: - Input Validation Tests
    
    @Test func testDiceCountValidation() {
        let gameState = GameState()
        
        // Test valid range
        gameState.updateTotalDice(20)
        #expect(gameState.totalDiceCount == 20, "Should accept valid dice count")
        
        // Test minimum bound
        gameState.updateTotalDice(0)
        #expect(gameState.totalDiceCount == 1, "Should clamp to minimum 1")
        
        gameState.updateTotalDice(-5)
        #expect(gameState.totalDiceCount == 1, "Should clamp negative to 1")
        
        // Test maximum bound
        gameState.updateTotalDice(50)
        #expect(gameState.totalDiceCount == 40, "Should clamp to maximum 40")
        
        gameState.updateTotalDice(100)
        #expect(gameState.totalDiceCount == 40, "Should clamp large values to 40")
    }
    
    @Test func testBidValidation() {
        let gameState = GameState()
        gameState.updateTotalDice(10)
        
        // Test valid range
        gameState.updateCurrentBid(5)
        #expect(gameState.currentBid == 5, "Should accept valid bid")
        
        // Test minimum bound
        gameState.updateCurrentBid(-1)
        #expect(gameState.currentBid == 0, "Should clamp to minimum 0")
        
        // Test maximum bound (should not exceed dice count)
        gameState.updateCurrentBid(15)
        #expect(gameState.currentBid == 10, "Should clamp to dice count")
        
        // Test that bid adjusts when dice count changes
        gameState.updateCurrentBid(8)
        gameState.updateTotalDice(5)
        #expect(gameState.currentBid == 5, "Bid should adjust when dice count decreases")
    }
    
    // MARK: - Increment/Decrement Tests
    
    @Test func testDiceIncrement() {
        let gameState = GameState()
        let initial = gameState.totalDiceCount
        
        gameState.incrementDice()
        #expect(gameState.totalDiceCount == initial + 1, "Should increment by 1")
        
        // Test at maximum
        gameState.updateTotalDice(40)
        gameState.incrementDice()
        #expect(gameState.totalDiceCount == 40, "Should not exceed maximum")
    }
    
    @Test func testDiceDecrement() {
        let gameState = GameState()
        let initial = gameState.totalDiceCount
        
        gameState.decrementDice()
        #expect(gameState.totalDiceCount == initial - 1, "Should decrement by 1")
        
        // Test at minimum
        gameState.updateTotalDice(1)
        gameState.decrementDice()
        #expect(gameState.totalDiceCount == 1, "Should not go below minimum")
    }
    
    @Test func testBidIncrement() {
        let gameState = GameState()
        gameState.updateTotalDice(10)
        gameState.updateCurrentBid(5)
        
        gameState.incrementBid()
        #expect(gameState.currentBid == 6, "Should increment by 1")
        
        // Test at maximum
        gameState.updateCurrentBid(10)
        gameState.incrementBid()
        #expect(gameState.currentBid == 10, "Should not exceed dice count")
    }
    
    @Test func testBidDecrement() {
        let gameState = GameState()
        gameState.updateCurrentBid(5)
        
        gameState.decrementBid()
        #expect(gameState.currentBid == 4, "Should decrement by 1")
        
        // Test at minimum
        gameState.updateCurrentBid(0)
        gameState.decrementBid()
        #expect(gameState.currentBid == 0, "Should not go below 0")
    }
    
    // MARK: - State Update Tests
    
    @Test func testProbabilityUpdates() {
        let gameState = GameState()
        
        // Set a known state
        gameState.updateTotalDice(6)
        gameState.updateCurrentBid(1)
        
        let probability = gameState.currentProbability
        let percentage = gameState.probabilityPercentage
        let color = gameState.probabilityColor
        
        // Verify probability is calculated
        #expect(probability > 0.0 && probability <= 1.0, "Probability should be valid")
        #expect(percentage.hasSuffix("%"), "Percentage should have % symbol")
        #expect([Color.red, Color.yellow, Color.green].contains(color), "Color should be valid")
        
        // Change bid and verify updates
        gameState.updateCurrentBid(6)
        #expect(gameState.currentProbability != probability, "Probability should update")
        #expect(gameState.probabilityPercentage != percentage, "Percentage should update")
    }
    
    @Test func testBreakEvenUpdates() {
        let gameState = GameState()
        
        gameState.updateTotalDice(10)
        let breakEven1 = gameState.breakEvenBid
        
        gameState.updateTotalDice(20)
        let breakEven2 = gameState.breakEvenBid
        
        // Break-even should update when dice count changes
        #expect(breakEven1 != breakEven2, "Break-even should update with dice count")
        #expect(breakEven2 > 0, "Break-even should be positive")
    }
    
    // MARK: - Color Coding Tests
    
    @Test func testColorCoding() {
        let gameState = GameState()
        
        // Test scenarios that should produce different colors
        gameState.updateTotalDice(6)
        
        // Low bid should have high probability (green)
        gameState.updateCurrentBid(0)
        #expect(gameState.probabilityColor == .green, "k=0 should be green")
        
        // High bid should have low probability (red)
        gameState.updateCurrentBid(6)
        #expect(gameState.probabilityColor == .red, "k=n should be red")
        
        // Test color transitions
        var previousColor = gameState.probabilityColor
        for bid in 0...6 {
            gameState.updateCurrentBid(bid)
            let currentColor = gameState.probabilityColor
            // Color should be one of the valid colors
            #expect([Color.red, Color.yellow, Color.green].contains(currentColor), 
                   "Color should be valid for bid \(bid)")
        }
    }
    
    // MARK: - Computed Properties Tests
    
    @Test func testIsAboveBreakEven() {
        let gameState = GameState()
        gameState.updateTotalDice(10)
        
        let breakEven = gameState.breakEvenBid
        
        // Bid at break-even should return true
        gameState.updateCurrentBid(breakEven)
        #expect(gameState.isAboveBreakEven, "Bid at break-even should be above break-even")
        
        // Bid below break-even should return true
        if breakEven > 0 {
            gameState.updateCurrentBid(breakEven - 1)
            #expect(gameState.isAboveBreakEven, "Bid below break-even should be above break-even")
        }
        
        // Bid above break-even should return false
        if breakEven < gameState.totalDiceCount {
            gameState.updateCurrentBid(breakEven + 1)
            #expect(!gameState.isAboveBreakEven, "Bid above break-even should not be above break-even")
        }
    }
    
    @Test func testProbabilityDescription() {
        let gameState = GameState()
        gameState.updateTotalDice(10)
        
        // Test different probability ranges
        gameState.updateCurrentBid(0) // Should be high probability
        let highDesc = gameState.probabilityDescription
        #expect(highDesc == "Favorable", "High probability should be 'Favorable'")
        
        gameState.updateCurrentBid(10) // Should be low probability
        let lowDesc = gameState.probabilityDescription
        #expect(lowDesc == "Unlikely", "Low probability should be 'Unlikely'")
        
        // Find a moderate probability if possible
        for bid in 1..<10 {
            gameState.updateCurrentBid(bid)
            if gameState.currentProbability >= 0.3 && gameState.currentProbability < 0.5 {
                #expect(gameState.probabilityDescription == "Moderate", 
                       "Moderate probability should be 'Moderate'")
                break
            }
        }
    }
    
    // MARK: - Performance Tests
    
    @Test func testUpdatePerformance() async {
        let gameState = GameState()
        let startTime = Date()
        
        // Perform many state updates
        for _ in 0..<100 {
            gameState.updateTotalDice(Int.random(in: 1...40))
            gameState.updateCurrentBid(Int.random(in: 0...gameState.totalDiceCount))
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let averageTime = elapsed / 100.0 * 1000.0 // Convert to milliseconds
        
        #expect(averageTime < 50.0, 
               "Average update time should be < 50ms, got \(averageTime)ms")
    }
    
    // MARK: - Observable Object Tests
    
    @Test func testObservableObjectUpdates() async {
        let gameState = GameState()
        var updateCount = 0
        
        // This is a simplified test - in a real app you'd use @Published property observers
        let initialDice = gameState.totalDiceCount
        let initialBid = gameState.currentBid
        
        gameState.updateTotalDice(initialDice + 1)
        #expect(gameState.totalDiceCount == initialDice + 1, "Dice count should update")
        
        gameState.updateCurrentBid(initialBid + 1)
        #expect(gameState.currentBid == initialBid + 1, "Bid should update")
    }
}