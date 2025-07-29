//
//  HandConfigurationTests.swift
//  liars-dice-app Watch AppTests
//
//  Unit tests for HandConfiguration model
//

import Testing
import Foundation
@testable import liars_dice_app_Watch_App

struct HandConfigurationTests {
    
    // MARK: - Initialization Tests
    
    @Test func testInitialization() {
        let config = HandConfiguration(diceCount: 5, bidFace: 3)
        
        #expect(config.diceCount == 5)
        #expect(config.bidFace == 3)
        #expect(config.faceValues.count == 5)
        #expect(config.faceValues.allSatisfy { $0 == nil })
        #expect(!config.isComplete())
        #expect(!config.hasAnyDiceSet())
    }
    
    @Test func testInitializationWithDefaults() {
        let config = HandConfiguration(diceCount: 3)
        
        #expect(config.diceCount == 3)
        #expect(config.bidFace == 1)
        #expect(config.faceValues.count == 3)
    }
    
    @Test func testBidFaceValidation() {
        var config = HandConfiguration(diceCount: 2, bidFace: 10)
        #expect(config.bidFace == 6) // Should clamp to max
        
        config = HandConfiguration(diceCount: 2, bidFace: -1)
        #expect(config.bidFace == 1) // Should clamp to min
    }
    
    // MARK: - Die Setting Tests
    
    @Test func testSetValidDie() {
        var config = HandConfiguration(diceCount: 3)
        
        #expect(config.setDie(at: 0, to: 5))
        #expect(config.getDie(at: 0) == 5)
        #expect(config.hasAnyDiceSet())
        #expect(!config.isComplete())
    }
    
    @Test func testSetInvalidDieIndex() {
        var config = HandConfiguration(diceCount: 3)
        
        #expect(!config.setDie(at: -1, to: 5))
        #expect(!config.setDie(at: 3, to: 5))
        #expect(!config.hasAnyDiceSet())
    }
    
    @Test func testSetInvalidDieValue() {
        var config = HandConfiguration(diceCount: 3)
        
        #expect(!config.setDie(at: 0, to: 0))
        #expect(!config.setDie(at: 0, to: 7))
        #expect(!config.setDie(at: 0, to: -1))
        #expect(config.getDie(at: 0) == nil)
    }
    
    @Test func testSetDieToNil() {
        var config = HandConfiguration(diceCount: 3)
        
        // Set then clear
        #expect(config.setDie(at: 0, to: 4))
        #expect(config.getDie(at: 0) == 4)
        
        #expect(config.setDie(at: 0, to: nil))
        #expect(config.getDie(at: 0) == nil)
    }
    
    // MARK: - Counting Tests
    
    @Test func testCountMatching() {
        var config = HandConfiguration(diceCount: 5)
        
        // Set some dice: [5, 3, 5, nil, 2]
        config.setDie(at: 0, to: 5)
        config.setDie(at: 1, to: 3)
        config.setDie(at: 2, to: 5)
        config.setDie(at: 4, to: 2)
        
        #expect(config.countMatching(face: 5) == 2)
        #expect(config.countMatching(face: 3) == 1)
        #expect(config.countMatching(face: 2) == 1)
        #expect(config.countMatching(face: 1) == 0)
        #expect(config.countMatching(face: 4) == 0)
        #expect(config.countMatching(face: 6) == 0)
    }
    
    @Test func testCountMatchingInvalidFace() {
        let config = HandConfiguration(diceCount: 3)
        
        #expect(config.countMatching(face: 0) == 0)
        #expect(config.countMatching(face: 7) == 0)
        #expect(config.countMatching(face: -1) == 0)
    }
    
    @Test func testCountMatchingBidFace() {
        var config = HandConfiguration(diceCount: 4, bidFace: 6)
        
        config.setDie(at: 0, to: 6)
        config.setDie(at: 1, to: 3)
        config.setDie(at: 2, to: 6)
        
        #expect(config.countMatchingBidFace() == 2)
        
        config.bidFace = 3
        #expect(config.countMatchingBidFace() == 1)
    }
    
    // MARK: - State Query Tests
    
    @Test func testIsComplete() {
        var config = HandConfiguration(diceCount: 3)
        
        #expect(!config.isComplete())
        
        config.setDie(at: 0, to: 1)
        config.setDie(at: 1, to: 2)
        #expect(!config.isComplete())
        
        config.setDie(at: 2, to: 3)
        #expect(config.isComplete())
    }
    
    @Test func testSetDiceCount() {
        var config = HandConfiguration(diceCount: 4)
        
        #expect(config.setDiceCount() == 0)
        
        config.setDie(at: 0, to: 1)
        config.setDie(at: 2, to: 3)
        #expect(config.setDiceCount() == 2)
        
        config.setDie(at: 1, to: 5)
        config.setDie(at: 3, to: 2)
        #expect(config.setDiceCount() == 4)
    }
    
    // MARK: - Reset Tests
    
    @Test func testReset() {
        var config = HandConfiguration(diceCount: 3)
        
        // Set all dice
        config.setDie(at: 0, to: 1)
        config.setDie(at: 1, to: 2)
        config.setDie(at: 2, to: 3)
        #expect(config.isComplete())
        
        // Reset all
        config.reset()
        #expect(!config.hasAnyDiceSet())
        #expect(!config.isComplete())
        #expect(config.setDiceCount() == 0)
    }
    
    @Test func testResetSingleDie() {
        var config = HandConfiguration(diceCount: 3)
        
        config.setDie(at: 0, to: 5)
        config.setDie(at: 1, to: 3)
        #expect(config.setDiceCount() == 2)
        
        #expect(config.resetDie(at: 0))
        #expect(config.getDie(at: 0) == nil)
        #expect(config.getDie(at: 1) == 3)
        #expect(config.setDiceCount() == 1)
        
        #expect(!config.resetDie(at: 5)) // Invalid index
    }
    
    // MARK: - Bulk Operations Tests
    
    @Test func testSetMultipleDice() {
        var config = HandConfiguration(diceCount: 5)
        
        let result = config.setDice(at: [0, 2, 4], to: 6)
        #expect(result == true)
        #expect(config.getDie(at: 0) == 6)
        #expect(config.getDie(at: 1) == nil)
        #expect(config.getDie(at: 2) == 6)
        #expect(config.getDie(at: 3) == nil)
        #expect(config.getDie(at: 4) == 6)
        #expect(config.countMatching(face: 6) == 3)
    }
    
    @Test func testSetMultipleDiceWithInvalidIndex() {
        var config = HandConfiguration(diceCount: 3)
        
        // Should return false due to invalid index, but valid indices should still be set
        let result = config.setDice(at: [0, 1, 5], to: 4)
        #expect(result == false)
        #expect(config.getDie(at: 0) == 4)
        #expect(config.getDie(at: 1) == 4)
    }
    
    // MARK: - Bid Face Tests
    
    @Test func testBidFaceModification() {
        var config = HandConfiguration(diceCount: 2, bidFace: 1)
        
        config.bidFace = 4
        #expect(config.bidFace == 4)
        
        config.bidFace = 6
        #expect(config.bidFace == 6)
        
        // Test invalid values are rejected
        config.bidFace = 0
        #expect(config.bidFace == 6) // Should remain unchanged
        
        config.bidFace = 7
        #expect(config.bidFace == 6) // Should remain unchanged
    }
    
    // MARK: - Hand Summary Tests
    
    @Test func testHandSummaryEmpty() {
        let config = HandConfiguration(diceCount: 3)
        #expect(config.handSummary() == "No dice set")
    }
    
    @Test func testHandSummarySingle() {
        var config = HandConfiguration(diceCount: 3)
        config.setDie(at: 0, to: 5)
        
        #expect(config.handSummary() == "1 five")
    }
    
    @Test func testHandSummaryMultiple() {
        var config = HandConfiguration(diceCount: 6)
        config.setDie(at: 0, to: 5)
        config.setDie(at: 1, to: 5)
        config.setDie(at: 2, to: 3)
        config.setDie(at: 3, to: 1)
        
        let summary = config.handSummary()
        #expect(summary.contains("1 one"))
        #expect(summary.contains("1 three"))
        #expect(summary.contains("2 fives"))
    }
    
    // MARK: - Equatable Tests
    
    @Test func testEquality() {
        var config1 = HandConfiguration(diceCount: 3, bidFace: 2)
        var config2 = HandConfiguration(diceCount: 3, bidFace: 2)
        
        #expect(config1 == config2)
        
        config1.setDie(at: 0, to: 5)
        #expect(config1 != config2)
        
        config2.setDie(at: 0, to: 5)
        #expect(config1 == config2)
        
        config1.bidFace = 3
        #expect(config1 != config2)
    }
    
    // MARK: - Edge Cases
    
    @Test func testSingleDieConfiguration() {
        var config = HandConfiguration(diceCount: 1, bidFace: 6)
        
        #expect(config.diceCount == 1)
        #expect(!config.isComplete())
        
        config.setDie(at: 0, to: 6)
        #expect(config.isComplete())
        #expect(config.countMatchingBidFace() == 1)
    }
    
    @Test func testGetInvalidDieIndex() {
        let config = HandConfiguration(diceCount: 2)
        
        #expect(config.getDie(at: -1) == nil)
        #expect(config.getDie(at: 2) == nil)
        #expect(config.getDie(at: 10) == nil)
    }
}