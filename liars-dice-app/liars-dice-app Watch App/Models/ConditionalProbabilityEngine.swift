//
//  ConditionalProbabilityEngine.swift
//  liars-dice-app Watch App
//
//  Conditional probability calculator for Screen 3 (confirmed hand entry)
//  Calculates P(at least k dice show specific face f | known dice configuration)
//  This is completely separate from ProbabilityEngine.swift to avoid any modifications
//

import Foundation
import SwiftUI

class ConditionalProbabilityEngine {
    static let shared = ConditionalProbabilityEngine()
    
    // Cache for frequently calculated results
    private var cache: [CacheKey: Double] = [:]
    private let maxCacheSize = 100
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Calculate conditional probability given known dice configuration
    /// - Parameters:
    ///   - bid: The minimum number of dice showing the bid face (k)
    ///   - totalDice: Total dice in play across all players (n_total)
    ///   - handConfig: Player's hand configuration with known dice
    /// - Returns: Probability as a value between 0 and 1
    func getConditionalProbability(bid: Int, totalDice: Int, handConfig: HandConfiguration) -> Double {
        // Validate inputs
        guard totalDice >= 1, totalDice <= 40 else { return 0 }
        guard bid >= 0, bid <= totalDice else { return 0 }
        guard handConfig.diceCount <= totalDice else { return 0 }
        
        // Get count of player's dice showing the bid face
        let myMatchingDice = handConfig.countMatchingBidFace()
        
        // DEBUG LOGGING
        print("=== ConditionalProbabilityEngine Debug ===")
        print("Bid count: \(bid)")
        print("Total dice: \(totalDice)")
        print("Bid face: \(handConfig.bidFace)")
        print("My dice count: \(handConfig.diceCount)")
        print("My matching dice: \(myMatchingDice)")
        print("Hand summary: \(handConfig.handSummary())")
        
        // Calculate remaining dice needed and unknown dice count
        let remainingNeeded = bid - myMatchingDice
        let unknownDice = totalDice - handConfig.diceCount
        
        print("Remaining needed: \(remainingNeeded)")
        print("Unknown dice: \(unknownDice)")
        
        // If we already have enough matching dice, probability is 100%
        if remainingNeeded <= 0 {
            print("Already have enough! Returning 100%")
            return 1.0
        }
        
        // If we need more dice than there are unknown dice, probability is 0%
        if remainingNeeded > unknownDice {
            print("Need more than available! Returning 0%")
            return 0.0
        }
        
        // Check cache first
        let cacheKey = CacheKey(
            remainingNeeded: remainingNeeded,
            unknownDice: unknownDice
        )
        
        if let cachedResult = cache[cacheKey] {
            return cachedResult
        }
        
        // Calculate conditional probability
        let probability = calculateBinomialProbability(
            k: remainingNeeded,
            n: unknownDice,
            p: 1.0/6.0  // Probability of rolling the bid face
        )
        
        // Cache the result
        cacheResult(key: cacheKey, value: probability)
        
        print("Final probability: \(probability) (\(Int(round(probability * 100)))%)")
        print("==========================================")
        
        return probability
    }
    
    /// Get conditional probability as a percentage string
    /// - Parameters:
    ///   - bid: The minimum number of dice showing the bid face
    ///   - totalDice: Total dice in play
    ///   - handConfig: Player's hand configuration
    /// - Returns: Formatted percentage string (e.g., "75%")
    func getConditionalProbabilityPercentage(bid: Int, totalDice: Int, handConfig: HandConfiguration) -> String {
        let probability = getConditionalProbability(bid: bid, totalDice: totalDice, handConfig: handConfig)
        let percentage = Int(round(probability * 100))
        return "\(percentage)%"
    }
    
    /// Get color for conditional probability based on thresholds
    /// - Parameters:
    ///   - bid: The minimum number of dice showing the bid face
    ///   - totalDice: Total dice in play
    ///   - handConfig: Player's hand configuration
    /// - Returns: SwiftUI Color (green ≥50%, yellow 30-49%, red <30%)
    func getConditionalProbabilityColor(bid: Int, totalDice: Int, handConfig: HandConfiguration) -> Color {
        let probability = getConditionalProbability(bid: bid, totalDice: totalDice, handConfig: handConfig)
        return getColorForProbability(probability)
    }
    
    /// Calculate probability improvement compared to original estimate
    /// - Parameters:
    ///   - bid: The minimum number of dice showing the bid face
    ///   - totalDice: Total dice in play
    ///   - handConfig: Player's hand configuration
    ///   - originalProbability: Original probability from ProbabilityEngine
    /// - Returns: Difference in probability (-1.0 to 1.0)
    func getProbabilityImprovement(bid: Int, totalDice: Int, handConfig: HandConfiguration, originalProbability: Double) -> Double {
        let conditionalProbability = getConditionalProbability(bid: bid, totalDice: totalDice, handConfig: handConfig)
        return conditionalProbability - originalProbability
    }
    
    /// Clear the probability cache
    func clearCache() {
        cache.removeAll()
    }
    
    // MARK: - Private Methods
    
    /// Calculate binomial probability P(X ≥ k) where X ~ Binomial(n, p)
    /// - Parameters:
    ///   - k: Minimum number of successes
    ///   - n: Number of trials
    ///   - p: Probability of success on each trial
    /// - Returns: Cumulative probability
    private func calculateBinomialProbability(k: Int, n: Int, p: Double) -> Double {
        guard k >= 0 && k <= n && n >= 0 else { return 0.0 }
        
        // P(X ≥ k) = Σ(x=k to n) C(n,x) * p^x * (1-p)^(n-x)
        var totalProbability = 0.0
        
        for x in k...n {
            let binomialCoeff = binomialCoefficient(n: n, k: x)
            let termProbability = binomialCoeff * pow(p, Double(x)) * pow(1.0 - p, Double(n - x))
            totalProbability += termProbability
        }
        
        return min(totalProbability, 1.0) // Ensure we don't exceed 1.0 due to floating point errors
    }
    
    /// Calculate binomial coefficient C(n, k) = n! / (k! * (n-k)!)
    /// Uses log computation to avoid overflow for large numbers
    /// - Parameters:
    ///   - n: Total items
    ///   - k: Items to choose
    /// - Returns: Binomial coefficient
    private func binomialCoefficient(n: Int, k: Int) -> Double {
        guard k >= 0 && k <= n else { return 0.0 }
        guard n > 0 else { return k == 0 ? 1.0 : 0.0 }
        
        // Use symmetry: C(n,k) = C(n,n-k)
        let k = min(k, n - k)
        
        if k == 0 { return 1.0 }
        
        // Calculate using logarithms to avoid overflow
        var logResult = 0.0
        for i in 0..<k {
            logResult += log(Double(n - i)) - log(Double(i + 1))
        }
        
        return exp(logResult)
    }
    
    /// Get color based on probability thresholds
    /// - Parameter probability: Probability value (0.0 to 1.0)
    /// - Returns: Color corresponding to probability range
    private func getColorForProbability(_ probability: Double) -> Color {
        if probability >= 0.5 {
            return .green
        } else if probability >= 0.3 {
            return .yellow
        } else {
            return .red
        }
    }
    
    /// Cache a calculation result
    /// - Parameters:
    ///   - key: Cache key
    ///   - value: Probability value to cache
    private func cacheResult(key: CacheKey, value: Double) {
        // Simple cache eviction: remove oldest entries if cache is full
        if cache.count >= maxCacheSize {
            let keysToRemove = Array(cache.keys.prefix(cache.count - maxCacheSize + 1))
            for keyToRemove in keysToRemove {
                cache.removeValue(forKey: keyToRemove)
            }
        }
        
        cache[key] = value
    }
}

// MARK: - Cache Key

private struct CacheKey: Hashable {
    let remainingNeeded: Int
    let unknownDice: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(remainingNeeded)
        hasher.combine(unknownDice)
    }
}