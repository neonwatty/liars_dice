//
//  ConditionalProbabilityEngineTests.swift
//  liars-dice-app Watch AppTests
//
//  Unit tests for ConditionalProbabilityEngine
//

import Testing
import Foundation
@testable import liars_dice_app_Watch_App

struct ConditionalProbabilityEngineTests {
    
    // MARK: - Basic Functionality Tests
    
    @Test func testSingletonPattern() {
        let engine1 = ConditionalProbabilityEngine.shared
        let engine2 = ConditionalProbabilityEngine.shared
        
        #expect(engine1 === engine2)
    }
    
    @Test func testBasicProbabilityCalculation() {
        let engine = ConditionalProbabilityEngine.shared
        var handConfig = HandConfiguration(diceCount: 2, bidFace: 3)
        
        // Set one die to match bid face
        handConfig.setDie(at: 0, to: 3)
        
        // Need at least 2 dice showing 3s with 10 total dice
        // Already have 1, need 1 more from 8 unknown dice
        let probability = engine.getConditionalProbability(bid: 2, totalDice: 10, handConfig: handConfig)
        
        // P(X ≥ 1) where X ~ Binomial(8, 1/6)
        let expected = 1.0 - pow(5.0/6.0, 8.0) // 1 - P(X = 0)
        
        #expect(abs(probability - expected) < 0.001)
    }
    
    @Test func testGuaranteedProbability() {
        let engine = ConditionalProbabilityEngine.shared
        var handConfig = HandConfiguration(diceCount: 3, bidFace: 5)
        
        // Set all dice to match bid face
        handConfig.setDie(at: 0, to: 5)
        handConfig.setDie(at: 1, to: 5)
        handConfig.setDie(at: 2, to: 5)
        
        // Need at least 2 dice showing 5s - we already have 3
        let probability = engine.getConditionalProbability(bid: 2, totalDice: 10, handConfig: handConfig)
        
        #expect(probability == 1.0)
    }
    
    @Test func testImpossibleProbability() {
        let engine = ConditionalProbabilityEngine.shared
        var handConfig = HandConfiguration(diceCount: 2, bidFace: 4)
        
        // Set dice to non-matching values
        handConfig.setDie(at: 0, to: 1)
        handConfig.setDie(at: 1, to: 2)
        
        // Need at least 5 dice showing 4s with only 3 unknown dice
        let probability = engine.getConditionalProbability(bid: 5, totalDice: 5, handConfig: handConfig)
        
        #expect(probability == 0.0)
    }
    
    // MARK: - Edge Cases
    
    @Test func testEmptyHandConfiguration() {
        let engine = ConditionalProbabilityEngine.shared
        let handConfig = HandConfiguration(diceCount: 3, bidFace: 2)
        
        // No dice set - should fall back to standard binomial calculation
        let probability = engine.getConditionalProbability(bid: 2, totalDice: 10, handConfig: handConfig)
        
        // P(X ≥ 2) where X ~ Binomial(7, 1/6) since 3 dice are unknown
        let expected = 1.0 - pow(5.0/6.0, 7.0) - 7.0 * (1.0/6.0) * pow(5.0/6.0, 6.0)
        
        #expect(abs(probability - expected) < 0.001)
    }
    
    @Test func testInvalidInputs() {
        let engine = ConditionalProbabilityEngine.shared
        let handConfig = HandConfiguration(diceCount: 3, bidFace: 2)
        
        // Invalid total dice
        #expect(engine.getConditionalProbability(bid: 2, totalDice: 0, handConfig: handConfig) == 0.0)
        #expect(engine.getConditionalProbability(bid: 2, totalDice: -1, handConfig: handConfig) == 0.0)
        #expect(engine.getConditionalProbability(bid: 2, totalDice: 50, handConfig: handConfig) == 0.0)
        
        // Invalid bid
        #expect(engine.getConditionalProbability(bid: -1, totalDice: 10, handConfig: handConfig) == 0.0)
        #expect(engine.getConditionalProbability(bid: 11, totalDice: 10, handConfig: handConfig) == 0.0)
        
        // Hand configuration has more dice than total
        let largeHandConfig = HandConfiguration(diceCount: 15, bidFace: 3)
        #expect(engine.getConditionalProbability(bid: 2, totalDice: 10, handConfig: largeHandConfig) == 0.0)
    }
    
    @Test func testBidFaceChange() {
        let engine = ConditionalProbabilityEngine.shared
        var handConfig = HandConfiguration(diceCount: 3, bidFace: 2)
        
        handConfig.setDie(at: 0, to: 2)
        handConfig.setDie(at: 1, to: 3)
        handConfig.setDie(at: 2, to: 2)
        
        // Count matching with bid face 2: should be 2
        let probability1 = engine.getConditionalProbability(bid: 2, totalDice: 10, handConfig: handConfig)
        
        // Change bid face to 3
        handConfig.bidFace = 3
        
        // Count matching with bid face 3: should be 1
        let probability2 = engine.getConditionalProbability(bid: 2, totalDice: 10, handConfig: handConfig)
        
        // Probability should be different since matching count changed
        #expect(probability1 != probability2)
    }
    
    // MARK: - Percentage and Color Tests
    
    @Test func testProbabilityPercentage() {
        let engine = ConditionalProbabilityEngine.shared
        var handConfig = HandConfiguration(diceCount: 1, bidFace: 6)
        handConfig.setDie(at: 0, to: 6)
        
        // Guaranteed case should return 100%
        let percentage = engine.getConditionalProbabilityPercentage(bid: 1, totalDice: 5, handConfig: handConfig)
        #expect(percentage == "100%")
        
        // Impossible case should return 0%
        handConfig.setDie(at: 0, to: 1)
        let zeroPercentage = engine.getConditionalProbabilityPercentage(bid: 5, totalDice: 5, handConfig: handConfig)
        #expect(zeroPercentage == "0%")
    }
    
    @Test func testProbabilityColors() {
        let engine = ConditionalProbabilityEngine.shared
        var handConfig = HandConfiguration(diceCount: 1, bidFace: 6)
        
        // High probability (guaranteed) - should be green
        handConfig.setDie(at: 0, to: 6)
        let greenColor = engine.getConditionalProbabilityColor(bid: 1, totalDice: 5, handConfig: handConfig)
        #expect(greenColor == .green)
        
        // Low probability (impossible) - should be red
        handConfig.setDie(at: 0, to: 1)
        let redColor = engine.getConditionalProbabilityColor(bid: 5, totalDice: 5, handConfig: handConfig)
        #expect(redColor == .red)
    }
    
    // MARK: - Probability Improvement Tests
    
    @Test func testProbabilityImprovement() {
        let engine = ConditionalProbabilityEngine.shared
        var handConfig = HandConfiguration(diceCount: 2, bidFace: 4)
        
        handConfig.setDie(at: 0, to: 4)
        handConfig.setDie(at: 1, to: 1)
        
        let originalProbability = 0.3
        let improvement = engine.getProbabilityImprovement(
            bid: 2, 
            totalDice: 10, 
            handConfig: handConfig, 
            originalProbability: originalProbability
        )
        
        // Should return difference between conditional and original
        let conditionalProb = engine.getConditionalProbability(bid: 2, totalDice: 10, handConfig: handConfig)
        let expectedImprovement = conditionalProb - originalProbability
        
        #expect(abs(improvement - expectedImprovement) < 0.001)
    }
    
    // MARK: - Performance Tests
    
    @Test func testCachingPerformance() {
        let engine = ConditionalProbabilityEngine.shared
        engine.clearCache()
        
        var handConfig = HandConfiguration(diceCount: 5, bidFace: 3)
        handConfig.setDie(at: 0, to: 3)
        handConfig.setDie(at: 1, to: 2)
        
        // First call - should calculate and cache
        let startTime1 = CFAbsoluteTimeGetCurrent()
        let prob1 = engine.getConditionalProbability(bid: 3, totalDice: 20, handConfig: handConfig)
        let duration1 = CFAbsoluteTimeGetCurrent() - startTime1
        
        // Second call - should use cache
        let startTime2 = CFAbsoluteTimeGetCurrent()
        let prob2 = engine.getConditionalProbability(bid: 3, totalDice: 20, handConfig: handConfig)
        let duration2 = CFAbsoluteTimeGetCurrent() - startTime2
        
        #expect(prob1 == prob2)
        #expect(duration2 < duration1) // Cache should be faster
    }
    
    @Test func testCalculationSpeed() {
        let engine = ConditionalProbabilityEngine.shared
        var handConfig = HandConfiguration(diceCount: 10, bidFace: 2)
        
        // Set some dice
        for i in 0..<5 {
            handConfig.setDie(at: i, to: i % 6 + 1)
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        _ = engine.getConditionalProbability(bid: 15, totalDice: 40, handConfig: handConfig)
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        
        // Should complete within 50ms (0.05 seconds)
        #expect(duration < 0.05)
    }
    
    // MARK: - Mathematical Accuracy Tests
    
    @Test func testBinomialCalculationAccuracy() {
        let engine = ConditionalProbabilityEngine.shared
        let handConfig = HandConfiguration(diceCount: 0, bidFace: 1)
        
        // Test against known binomial probabilities
        // P(X ≥ 1) where X ~ Binomial(6, 1/6) ≈ 0.6651
        let prob1 = engine.getConditionalProbability(bid: 1, totalDice: 6, handConfig: handConfig)
        #expect(abs(prob1 - 0.6651) < 0.01)
        
        // P(X ≥ 2) where X ~ Binomial(6, 1/6) ≈ 0.2649
        let prob2 = engine.getConditionalProbability(bid: 2, totalDice: 6, handConfig: handConfig)
        #expect(abs(prob2 - 0.2649) < 0.01)
    }
    
    @Test func testSymmetryProperty() {
        let engine = ConditionalProbabilityEngine.shared
        
        // Test that results are consistent regardless of which dice are set
        var handConfig1 = HandConfiguration(diceCount: 3, bidFace: 4)
        handConfig1.setDie(at: 0, to: 4)
        handConfig1.setDie(at: 1, to: 2)
        
        var handConfig2 = HandConfiguration(diceCount: 3, bidFace: 4)
        handConfig2.setDie(at: 1, to: 4)
        handConfig2.setDie(at: 2, to: 2)
        
        let prob1 = engine.getConditionalProbability(bid: 2, totalDice: 10, handConfig: handConfig1)
        let prob2 = engine.getConditionalProbability(bid: 2, totalDice: 10, handConfig: handConfig2)
        
        #expect(abs(prob1 - prob2) < 0.001)
    }
    
    // MARK: - Cache Management Tests
    
    @Test func testCacheClear() {
        let engine = ConditionalProbabilityEngine.shared
        var handConfig = HandConfiguration(diceCount: 2, bidFace: 5)
        handConfig.setDie(at: 0, to: 5)
        
        // Calculate to populate cache
        _ = engine.getConditionalProbability(bid: 2, totalDice: 8, handConfig: handConfig)
        
        // Clear cache
        engine.clearCache()
        
        // Should still work correctly after cache clear
        let probability = engine.getConditionalProbability(bid: 2, totalDice: 8, handConfig: handConfig)
        #expect(probability > 0.0 && probability <= 1.0)
    }
}