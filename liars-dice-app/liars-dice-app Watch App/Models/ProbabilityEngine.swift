//
//  ProbabilityEngine.swift
//  liars-dice-app Watch App
//
//  Singleton class that handles all probability calculations for Liar's Dice
//  Calculates P(at least k dice show ANY face value) - not a specific face
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
    
    /// Get the probability that at least k dice show ANY face value
    /// - Parameters:
    ///   - bid: The minimum number of dice showing the same face (k)
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
    
    /// Get the break-even bid K₀ (highest bid where P(ANY face appears k+ times) ≥ 50%)
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
    
    /// Compute probability that at least k dice show ANY face value
    /// This calculates P(there exists a face value that appears at least k times)
    private static func computeCumulativeProbability(n: Int, k: Int) -> Double {
        if k > n { return 0 }
        if k == 0 { return 1 }
        if k == 1 { return 1 }  // At least 1 die shows some face is always true
        
        // For k > n/6, we can use a more efficient calculation
        if Double(k) > Double(n) / 6.0 + 3.0 * sqrt(Double(n) * 5.0 / 36.0) {
            // When k is much larger than expected, use approximation
            return computeHighKProbability(n: n, k: k)
        }
        
        // For general case, calculate 1 - P(all faces appear fewer than k times)
        // This uses inclusion-exclusion principle
        return computeGeneralProbability(n: n, k: k)
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
    
    /// Compute probability for general case using inclusion-exclusion
    private static func computeGeneralProbability(n: Int, k: Int) -> Double {
        // Special cases
        if k == 2 && n <= 10 {
            // For small n and k=2, use exact calculation
            return computeExactK2Probability(n: n)
        }
        
        // For larger cases, use multinomial approach
        // P(at least one face appears k+ times) = 1 - P(all faces appear <k times)
        
        // We'll use an approximation based on the birthday problem generalization
        // and Poisson approximation for larger values
        
        let p = 1.0 / 6.0  // probability of any specific face
        let lambda = Double(n) * p  // expected occurrences of each face
        
        // Use Poisson approximation for probability that a specific face appears k+ times
        var probSpecificFace = 0.0
        for j in k...n {
            probSpecificFace += poissonPMF(k: j, lambda: lambda)
        }
        
        // Bonferroni bound: P(at least one of 6 faces appears k+ times) ≤ 6 * P(specific face appears k+ times)
        // For better approximation, account for overlap
        let probAnyFace = 1.0 - pow(1.0 - probSpecificFace, 6.0)
        
        return min(probAnyFace, 1.0)
    }
    
    /// Compute exact probability for k=2 case
    private static func computeExactK2Probability(n: Int) -> Double {
        // P(at least 2 dice match) = 1 - P(all dice different)
        if n > 6 { return 1.0 }  // Can't have all different if more than 6 dice
        
        // P(all different) = 6!/((6-n)! * 6^n)
        var numerator = 1.0
        for i in 0..<n {
            numerator *= Double(6 - i)
        }
        let denominator = pow(6.0, Double(n))
        
        return 1.0 - (numerator / denominator)
    }
    
    /// Compute probability for high k values (when k is unlikely)
    private static func computeHighKProbability(n: Int, k: Int) -> Double {
        // When k is much higher than n/6, the probability becomes very small
        // Use union bound with Poisson approximation
        
        let lambda = Double(n) / 6.0
        var prob = 0.0
        
        // Calculate probability for each face value
        for _ in 0..<6 {
            var faceProb = 0.0
            for j in k...n {
                faceProb += poissonPMF(k: j, lambda: lambda)
            }
            prob += faceProb
        }
        
        // Apply Bonferroni correction for union of events
        prob = min(prob, 1.0)
        
        // For very high k, use tighter bound
        if Double(k) > lambda + 4.0 * sqrt(lambda) {
            // Use Chernoff bound for tighter estimate
            let mu = 6.0 * exp(-pow(Double(k) - lambda, 2.0) / (2.0 * lambda))
            prob = min(mu, prob)
        }
        
        return prob
    }
    
    /// Poisson probability mass function
    private static func poissonPMF(k: Int, lambda: Double) -> Double {
        if k < 0 { return 0 }
        
        // Use log to avoid overflow
        let logProb = Double(k) * log(lambda) - lambda - logFactorial(k)
        return exp(logProb)
    }
    
    /// Log factorial for Poisson calculation
    private static func logFactorial(_ n: Int) -> Double {
        if n <= 1 { return 0 }
        
        var result = 0.0
        for i in 2...n {
            result += log(Double(i))
        }
        return result
    }
}