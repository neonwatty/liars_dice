//
//  ConditionalProbabilityDebugTests.swift
//  liars-dice-app Watch AppTests
//
//  Debug tests to identify the conditional probability issue
//

import XCTest
@testable import liars_dice_app_Watch_App

class ConditionalProbabilityDebugTests: XCTestCase {
    
    func testUserReportedScenario() {
        // Test the exact scenario the user reported:
        // Total dice: 10, bid count: 3, bid face: 1 (ones)
        // Player has 3 dice all showing 1s
        // Expected: 100%
        
        print("\n=== DEBUG TEST: User Reported Scenario ===")
        
        // Create hand configuration with 3 dice
        var handConfig = HandConfiguration(diceCount: 3, bidFace: 1)
        
        // Set all 3 dice to show 1s
        handConfig.setDie(at: 0, to: 1)
        handConfig.setDie(at: 1, to: 1)
        handConfig.setDie(at: 2, to: 1)
        
        print("Hand configuration created:")
        print("- Dice count: \(handConfig.diceCount)")
        print("- Bid face: \(handConfig.bidFace)")
        print("- Face values: \(handConfig.faceValues)")
        print("- Hand summary: \(handConfig.handSummary())")
        
        // Test counting
        let matchingCount = handConfig.countMatchingBidFace()
        print("\nCounting test:")
        print("- countMatchingBidFace() returned: \(matchingCount)")
        print("- Expected: 3")
        
        XCTAssertEqual(matchingCount, 3, "Should count 3 dice showing face 1")
        
        // Calculate conditional probability
        let engine = ConditionalProbabilityEngine.shared
        let probability = engine.getConditionalProbability(
            bid: 3,
            totalDice: 10,
            handConfig: handConfig
        )
        
        print("\nConditional probability result:")
        print("- Probability: \(probability)")
        print("- Percentage: \(Int(round(probability * 100)))%")
        print("- Expected: 100%")
        
        XCTAssertEqual(probability, 1.0, accuracy: 0.001, "Should be 100% when player already has 3 ones")
    }
    
    func testPartialMatch() {
        print("\n=== DEBUG TEST: Partial Match ===")
        
        // Total dice: 10, bid count: 5, bid face: 2 (twos)
        // Player has 3 dice: 2 twos, 1 three
        var handConfig = HandConfiguration(diceCount: 3, bidFace: 2)
        
        handConfig.setDie(at: 0, to: 2)
        handConfig.setDie(at: 1, to: 2)
        handConfig.setDie(at: 2, to: 3)
        
        print("Hand configuration:")
        print("- Face values: \(handConfig.faceValues)")
        print("- Bid face: \(handConfig.bidFace)")
        print("- Matching dice: \(handConfig.countMatchingBidFace())")
        
        let engine = ConditionalProbabilityEngine.shared
        let probability = engine.getConditionalProbability(
            bid: 5,
            totalDice: 10,
            handConfig: handConfig
        )
        
        print("\nNeed 3 more twos among 7 unknown dice")
        print("Probability: \(Int(round(probability * 100)))%")
        
        // Should be less than 100% but greater than 0%
        XCTAssertLessThan(probability, 1.0)
        XCTAssertGreaterThan(probability, 0.0)
    }
    
    func testNoMatches() {
        print("\n=== DEBUG TEST: No Matches ===")
        
        // Total dice: 10, bid count: 4, bid face: 6 (sixes)
        // Player has 3 dice: none showing sixes
        var handConfig = HandConfiguration(diceCount: 3, bidFace: 6)
        
        handConfig.setDie(at: 0, to: 1)
        handConfig.setDie(at: 1, to: 2)
        handConfig.setDie(at: 2, to: 3)
        
        print("Hand configuration:")
        print("- Face values: \(handConfig.faceValues)")
        print("- Bid face: \(handConfig.bidFace)")
        print("- Matching dice: \(handConfig.countMatchingBidFace())")
        
        let engine = ConditionalProbabilityEngine.shared
        let probability = engine.getConditionalProbability(
            bid: 4,
            totalDice: 10,
            handConfig: handConfig
        )
        
        print("\nNeed 4 sixes among 7 unknown dice")
        print("Probability: \(Int(round(probability * 100)))%")
        
        // Should be less than 50% (needing 4 out of 7 at 1/6 probability each)
        XCTAssertLessThan(probability, 0.5)
    }
}