//
//  SpecificFaceProbabilityEngineTests.swift
//  liars-dice-app Watch AppTests
//
//  Tests for specific face probability calculations
//

import XCTest
@testable import liars_dice_app_Watch_App

class SpecificFaceProbabilityEngineTests: XCTestCase {
    private let engine = SpecificFaceProbabilityEngine.shared
    private let epsilon = 0.01 // Allow 1% error for floating point comparisons
    
    override func setUp() {
        super.setUp()
        engine.clearCache()
    }
    
    // MARK: - Basic Tests
    
    func testEdgeCases() {
        // Test bid of 0 - always 100%
        XCTAssertEqual(engine.getProbability(bid: 0, totalDice: 10), 1.0)
        
        // Test bid greater than total dice - always 0%
        XCTAssertEqual(engine.getProbability(bid: 11, totalDice: 10), 0.0)
        
        // Test invalid inputs
        XCTAssertEqual(engine.getProbability(bid: 5, totalDice: 0), 0.0)
        XCTAssertEqual(engine.getProbability(bid: -1, totalDice: 10), 0.0)
    }
    
    func testSingleDie() {
        // With 1 die, probability of getting specific face is exactly 1/6
        let prob = engine.getProbability(bid: 1, totalDice: 1)
        XCTAssertEqual(prob, 1.0/6.0, accuracy: epsilon)
    }
    
    func testExpectedValue() {
        // With 6 dice, expected number of any specific face is 1
        // P(≥1) should be fairly high
        let prob = engine.getProbability(bid: 1, totalDice: 6)
        XCTAssertGreaterThan(prob, 0.6)
        XCTAssertLessThan(prob, 0.7)
        
        // P(≥2) should be lower
        let prob2 = engine.getProbability(bid: 2, totalDice: 6)
        XCTAssertLessThan(prob2, prob)
        XCTAssertGreaterThan(prob2, 0.2)
    }
    
    // MARK: - Comparison with Known Values
    
    func testKnownProbabilities() {
        // Test some hand-calculated values
        // With 3 dice, P(at least 1 shows specific face) = 1 - (5/6)^3 ≈ 0.421
        let prob3_1 = engine.getProbability(bid: 1, totalDice: 3)
        XCTAssertEqual(prob3_1, 0.421, accuracy: epsilon)
        
        // With 10 dice, P(at least 2 show specific face)
        // This is harder to calculate by hand but should be around 0.515
        let prob10_2 = engine.getProbability(bid: 2, totalDice: 10)
        XCTAssertEqual(prob10_2, 0.515, accuracy: 0.02)
    }
    
    // MARK: - Monotonicity Tests
    
    func testMonotonicityInBid() {
        // For fixed total dice, probability should decrease as bid increases
        let totalDice = 20
        var prevProb = 1.0
        
        for bid in 0...20 {
            let prob = engine.getProbability(bid: bid, totalDice: totalDice)
            XCTAssertLessThanOrEqual(prob, prevProb + epsilon)
            prevProb = prob
        }
    }
    
    func testMonotonicityInDice() {
        // For fixed bid, probability should increase as total dice increases
        let bid = 3
        var prevProb = 0.0
        
        for totalDice in bid...30 {
            let prob = engine.getProbability(bid: bid, totalDice: totalDice)
            XCTAssertGreaterThanOrEqual(prob, prevProb - epsilon)
            prevProb = prob
        }
    }
    
    // MARK: - Color Tests
    
    func testColorThresholds() {
        // Test that colors match probability thresholds
        
        // High probability (≥50%) should be green
        let greenProb = engine.getProbability(bid: 1, totalDice: 5)
        XCTAssertGreaterThan(greenProb, 0.5)
        XCTAssertEqual(engine.getProbabilityColor(bid: 1, totalDice: 5), .green)
        
        // Medium probability (30-49%) should be yellow
        let yellowProb = engine.getProbability(bid: 2, totalDice: 6)
        XCTAssertGreaterThan(yellowProb, 0.3)
        XCTAssertLessThan(yellowProb, 0.5)
        XCTAssertEqual(engine.getProbabilityColor(bid: 2, totalDice: 6), .yellow)
        
        // Low probability (<30%) should be red
        let redProb = engine.getProbability(bid: 5, totalDice: 10)
        XCTAssertLessThan(redProb, 0.3)
        XCTAssertEqual(engine.getProbabilityColor(bid: 5, totalDice: 10), .red)
    }
    
    // MARK: - Cache Tests
    
    func testCaching() {
        // Clear cache first
        engine.clearCache()
        
        // First call should calculate
        let start1 = Date()
        let prob1 = engine.getProbability(bid: 10, totalDice: 40)
        let time1 = Date().timeIntervalSince(start1)
        
        // Second call should use cache and be much faster
        let start2 = Date()
        let prob2 = engine.getProbability(bid: 10, totalDice: 40)
        let time2 = Date().timeIntervalSince(start2)
        
        XCTAssertEqual(prob1, prob2)
        XCTAssertLessThan(time2, time1 * 0.1) // Cache should be at least 10x faster
    }
    
    // MARK: - Integration with Game State
    
    func testComparisonWithAnyFaceProbability() {
        // Specific face probability should always be less than or equal to ANY face probability
        let probEngine = ProbabilityEngine.shared
        
        for totalDice in [5, 10, 20, 30] {
            for bid in 1...min(10, totalDice) {
                let specificProb = engine.getProbability(bid: bid, totalDice: totalDice)
                let anyProb = probEngine.getProbability(bid: bid, totalDice: totalDice)
                
                // Specific face probability should be much less than any face probability
                XCTAssertLessThan(specificProb, anyProb)
                
                // For small bids, any face is roughly 6x more likely than specific face
                if bid <= totalDice / 6 {
                    XCTAssertLessThan(specificProb * 4, anyProb)
                }
            }
        }
    }
}