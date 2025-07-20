//
//  ProbabilityEngineTests.swift
//  liars-dice-app Watch AppTests
//
//  Unit tests for the ProbabilityEngine class
//

import Testing
import Foundation
@testable import liars_dice_app_Watch_App

struct ProbabilityEngineTests {
    let engine = ProbabilityEngine.shared
    
    // MARK: - Basic Probability Tests
    
    @Test func testProbabilityBounds() {
        // Test that probabilities are always between 0 and 1
        for n in 1...40 {
            for k in 0...n {
                let probability = engine.getProbability(bid: k, totalDice: n)
                #expect(probability >= 0.0 && probability <= 1.0, 
                       "Probability for n=\(n), k=\(k) should be between 0 and 1, got \(probability)")
            }
        }
    }
    
    @Test func testProbabilityEdgeCases() {
        // k=0 should always have probability 1.0 (at least 0 dice showing)
        for n in 1...40 {
            let probability = engine.getProbability(bid: 0, totalDice: n)
            #expect(probability == 1.0, 
                   "Probability for k=0 should always be 1.0, got \(probability) for n=\(n)")
        }
        
        // k=1 should always have probability 1.0 (at least 1 die shows ANY face)
        for n in 1...40 {
            let probability = engine.getProbability(bid: 1, totalDice: n)
            #expect(probability == 1.0, 
                   "Probability for k=1 should always be 1.0, got \(probability) for n=\(n)")
        }
        
        // k=n should have lowest probability for given n
        for n in 1...20 {
            let probK0 = engine.getProbability(bid: 0, totalDice: n)
            let probKn = engine.getProbability(bid: n, totalDice: n)
            #expect(probK0 >= probKn, 
                   "P(k=0) should be >= P(k=n), got P(0)=\(probK0), P(\(n))=\(probKn)")
        }
    }
    
    @Test func testProbabilityDecreasing() {
        // Probability should decrease as k increases for fixed n
        for n in 2...20 {
            for k in 0..<n {
                let prob1 = engine.getProbability(bid: k, totalDice: n)
                let prob2 = engine.getProbability(bid: k + 1, totalDice: n)
                #expect(prob1 >= prob2, 
                       "Probability should decrease as k increases: P(\(k))=\(prob1) should be >= P(\(k+1))=\(prob2)")
            }
        }
    }
    
    // MARK: - Known Value Tests
    
    @Test func testKnownProbabilities() {
        // Test some known probability values for ANY face matching
        
        // For n=1, k=1: P(at least 1 die shows ANY face) = 1.0
        let prob1_1 = engine.getProbability(bid: 1, totalDice: 1)
        #expect(prob1_1 == 1.0, 
               "P(k=1|n=1) should be 1.0, got \(prob1_1)")
        
        // For n=6, k=2: P(at least 2 dice match) ≈ 98.46%
        let prob6_2 = engine.getProbability(bid: 2, totalDice: 6)
        #expect(prob6_2 > 0.98 && prob6_2 < 0.99, 
               "P(k=2|n=6) should be around 0.9846, got \(prob6_2)")
        
        // For n=2, k=2: P(both dice match) = 1/6
        let prob2_2 = engine.getProbability(bid: 2, totalDice: 2)
        #expect(abs(prob2_2 - (1.0/6.0)) < 0.01, 
               "P(k=2|n=2) should be ~0.1667, got \(prob2_2)")
        
        // For very high k relative to n, probability should be very low
        let prob10_9 = engine.getProbability(bid: 9, totalDice: 10)
        #expect(prob10_9 < 0.01, 
               "P(k=9|n=10) should be very low, got \(prob10_9)")
    }
    
    // MARK: - Input Validation Tests
    
    @Test func testInputValidation() {
        // Test invalid inputs return 0
        #expect(engine.getProbability(bid: -1, totalDice: 5) == 0.0, 
               "Negative bid should return 0")
        #expect(engine.getProbability(bid: 5, totalDice: 0) == 0.0, 
               "Zero dice should return 0")
        #expect(engine.getProbability(bid: 5, totalDice: 4) == 0.0, 
               "Bid > dice should return 0")
        #expect(engine.getProbability(bid: 5, totalDice: 41) == 0.0, 
               "Dice > 40 should return 0")
    }
    
    // MARK: - Break-Even Tests
    
    @Test func testBreakEvenCalculation() {
        // Test known break-even values for the new formula
        // k=1 should always have 100% probability
        for n in 1...5 {
            let breakEven = engine.getBreakEvenBid(totalDice: n)
            #expect(breakEven >= 1, 
                   "Break-even should be at least 1 for n=\(n), got \(breakEven)")
        }
        
        // For larger n, break-even should increase
        let breakEven10 = engine.getBreakEvenBid(totalDice: 10)
        let breakEven20 = engine.getBreakEvenBid(totalDice: 20)
        #expect(breakEven20 >= breakEven10, 
               "Break-even should increase with more dice")
        
        // Verify break-even properties
        for n in [6, 12, 18, 24] {
            let breakEven = engine.getBreakEvenBid(totalDice: n)
            
            // Break-even should be valid bid
            #expect(breakEven >= 0 && breakEven <= n, 
                   "Break-even bid \(breakEven) should be between 0 and \(n)")
            
            // Probability at break-even should be >= 50%
            let probAtBreakEven = engine.getProbability(bid: breakEven, totalDice: n)
            #expect(probAtBreakEven >= 0.5, 
                   "Probability at break-even \(breakEven) should be >= 50%, got \(probAtBreakEven)")
            
            // Probability at break-even + 1 should be < 50% (if valid)
            if breakEven < n {
                let probAboveBreakEven = engine.getProbability(bid: breakEven + 1, totalDice: n)
                #expect(probAboveBreakEven < 0.5, 
                       "Probability above break-even should be < 50%, got \(probAboveBreakEven)")
            }
        }
    }
    
    @Test func testBreakEvenInputValidation() {
        #expect(engine.getBreakEvenBid(totalDice: 0) == 0, 
               "Break-even for 0 dice should be 0")
        #expect(engine.getBreakEvenBid(totalDice: 41) == 0, 
               "Break-even for >40 dice should be 0")
    }
    
    // MARK: - Color Coding Tests
    
    @Test func testColorThresholds() {
        // Test that color coding follows expected thresholds
        
        // Create scenarios for each color
        let highProb = 0.8  // Should be green
        let medProb = 0.4   // Should be yellow  
        let lowProb = 0.1   // Should be red
        
        #expect(engine.getColorForProbability(highProb) == .green, 
               "80% probability should be green")
        #expect(engine.getColorForProbability(medProb) == .yellow, 
               "40% probability should be yellow")
        #expect(engine.getColorForProbability(lowProb) == .red, 
               "10% probability should be red")
        
        // Test boundary conditions
        #expect(engine.getColorForProbability(0.5) == .green, 
               "Exactly 50% should be green")
        #expect(engine.getColorForProbability(0.49) == .yellow, 
               "49% should be yellow")
        #expect(engine.getColorForProbability(0.3) == .yellow, 
               "Exactly 30% should be yellow")
        #expect(engine.getColorForProbability(0.29) == .red, 
               "29% should be red")
    }
    
    // MARK: - Performance Tests
    
    @Test func testPerformance() async {
        let startTime = Date()
        
        // Run many probability calculations
        for _ in 0..<1000 {
            let n = Int.random(in: 1...40)
            let k = Int.random(in: 0...n)
            _ = engine.getProbability(bid: k, totalDice: n)
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let averageTime = elapsed / 1000.0 * 1000.0 // Convert to milliseconds
        
        #expect(averageTime < 50.0, 
               "Average calculation time should be < 50ms, got \(averageTime)ms")
    }
    
    // MARK: - Percentage Formatting Tests
    
    @Test func testPercentageFormatting() {
        // k=0 and k=1 should both format as 100%
        let percentage0 = engine.getProbabilityPercentage(bid: 0, totalDice: 10)
        #expect(percentage0 == "100%", 
               "k=0 should format as 100%, got \(percentage0)")
        
        let percentage1 = engine.getProbabilityPercentage(bid: 1, totalDice: 10)
        #expect(percentage1 == "100%", 
               "k=1 should format as 100%, got \(percentage1)")
        
        // Test that percentage is always in valid format
        for n in 1...10 {
            for k in 0...n {
                let percentage = engine.getProbabilityPercentage(bid: k, totalDice: n)
                #expect(percentage.hasSuffix("%"), 
                       "Percentage should end with %, got \(percentage)")
                
                // Extract number part and verify it's 0-100
                let numberPart = String(percentage.dropLast())
                if let number = Int(numberPart) {
                    #expect(number >= 0 && number <= 100, 
                           "Percentage number should be 0-100, got \(number)")
                }
            }
        }
    }
}