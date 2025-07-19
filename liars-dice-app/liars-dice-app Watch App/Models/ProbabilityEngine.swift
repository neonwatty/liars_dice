//
//  ProbabilityEngine.swift
//  liars-dice-app Watch App
//
//  Singleton class that handles all probability calculations for Liar's Dice
//

import Foundation
import SwiftUI

class ProbabilityEngine {
    static let shared = ProbabilityEngine()
    
    private let lookupTable: ProbabilityLookupTable
    private var breakEvenCache: [Int: Int] = [:]
    
    private init() {
        self.lookupTable = ProbabilityLookupTable()
    }
    
    /// Get the probability P(k|n) for a given bid
    /// - Parameters:
    ///   - bid: The number of dice claimed (k)
    ///   - totalDice: The total number of dice in play (n)
    /// - Returns: Probability as a value between 0 and 1
    func getProbability(bid: Int, totalDice: Int) -> Double {
        guard totalDice >= 1, totalDice <= 40 else { return 0 }
        guard bid >= 0, bid <= totalDice else { return 0 }
        
        return lookupTable.getProbability(n: totalDice, k: bid)
    }
    
    /// Get the probability as a percentage string
    func getProbabilityPercentage(bid: Int, totalDice: Int) -> String {
        let probability = getProbability(bid: bid, totalDice: totalDice)
        let percentage = Int(round(probability * 100))
        return "\(percentage)%"
    }
    
    /// Get the break-even bid K₀ (highest bid with P ≥ 50%)
    /// - Parameter totalDice: The total number of dice in play
    /// - Returns: The break-even bid value
    func getBreakEvenBid(totalDice: Int) -> Int {
        guard totalDice >= 1, totalDice <= 40 else { return 0 }
        
        // Check cache first
        if let cached = breakEvenCache[totalDice] {
            return cached
        }
        
        // Binary search for break-even point
        var left = 0
        var right = totalDice
        var result = 0
        
        while left <= right {
            let mid = (left + right) / 2
            let probability = getProbability(bid: mid, totalDice: totalDice)
            
            if probability >= 0.5 {
                result = mid
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        // Cache the result
        breakEvenCache[totalDice] = result
        return result
    }
    
    /// Get the color for a given probability based on thresholds
    /// - Parameter probability: Probability value between 0 and 1
    /// - Returns: SwiftUI Color based on probability thresholds
    func getColorForProbability(_ probability: Double) -> Color {
        if probability >= 0.5 {
            return .green
        } else if probability >= 0.3 {
            return .yellow
        } else {
            return .red
        }
    }
    
    /// Get the color for a given bid
    func getColorForBid(bid: Int, totalDice: Int) -> Color {
        let probability = getProbability(bid: bid, totalDice: totalDice)
        return getColorForProbability(probability)
    }
}

// MARK: - Probability Lookup Table

private class ProbabilityLookupTable {
    private let probabilities: [Double]
    private let maxDice = 40
    
    init() {
        // Precompute all probabilities at initialization
        var computedProbabilities: [Double] = []
        
        for n in 0...maxDice {
            for k in 0...n {
                let probability = ProbabilityLookupTable.computeCumulativeProbability(n: n, k: k)
                computedProbabilities.append(probability)
            }
        }
        
        self.probabilities = computedProbabilities
    }
    
    /// Get probability from the lookup table
    func getProbability(n: Int, k: Int) -> Double {
        guard n >= 0, n <= maxDice, k >= 0, k <= n else { return 0 }
        
        // Calculate index in flattened array
        let index = (n * (n + 1)) / 2 + k
        return probabilities[index]
    }
    
    /// Compute cumulative binomial probability P(X ≥ k | n, p=1/6)
    private static func computeCumulativeProbability(n: Int, k: Int) -> Double {
        if k > n { return 0 }
        if k == 0 { return 1 }
        
        var cumulative = 0.0
        
        for x in k...n {
            let logBinCoef = logBinomialCoefficient(n: n, k: x)
            let logProb = logBinCoef + Double(x) * log(1.0/6.0) + Double(n - x) * log(5.0/6.0)
            cumulative += exp(logProb)
        }
        
        return min(cumulative, 1.0)
    }
    
    /// Calculate log of binomial coefficient to avoid overflow
    private static func logBinomialCoefficient(n: Int, k: Int) -> Double {
        if k > n || k < 0 { return -Double.infinity }
        if k == 0 || k == n { return 0 }
        
        let k = min(k, n - k) // Take advantage of symmetry
        
        var result = 0.0
        for i in 0..<k {
            result += log(Double(n - i)) - log(Double(i + 1))
        }
        
        return result
    }
}