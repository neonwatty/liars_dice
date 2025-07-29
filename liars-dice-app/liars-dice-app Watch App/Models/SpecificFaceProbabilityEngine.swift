//
//  SpecificFaceProbabilityEngine.swift
//  liars-dice-app Watch App
//
//  Calculates probability for a SPECIFIC face value (not ANY face)
//  P(at least k dice show specific face f)
//

import Foundation
import SwiftUI

class SpecificFaceProbabilityEngine {
    static let shared = SpecificFaceProbabilityEngine()
    
    // Cache for frequently calculated results
    private var cache: [CacheKey: Double] = [:]
    private let maxCacheSize = 200
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Calculate probability that at least k dice show a specific face value
    /// - Parameters:
    ///   - bid: The minimum number of dice showing the specific face (k)
    ///   - totalDice: Total dice in play (n)
    /// - Returns: Probability as a value between 0 and 1
    func getProbability(bid: Int, totalDice: Int) -> Double {
        // Validate inputs
        guard totalDice >= 1, totalDice <= 40 else { return 0 }
        guard bid >= 0, bid <= totalDice else { return 0 }
        
        // Special cases
        if bid == 0 { return 1.0 }
        if bid > totalDice { return 0.0 }
        
        // Check cache first
        let cacheKey = CacheKey(bid: bid, totalDice: totalDice)
        if let cachedResult = cache[cacheKey] {
            return cachedResult
        }
        
        // Calculate binomial probability P(X >= k) where X ~ Binomial(n, 1/6)
        let probability = calculateBinomialProbability(
            k: bid,
            n: totalDice,
            p: 1.0/6.0
        )
        
        // Cache the result
        cacheResult(key: cacheKey, value: probability)
        
        return probability
    }
    
    /// Get probability as a percentage string
    func getProbabilityPercentage(bid: Int, totalDice: Int) -> String {
        let probability = getProbability(bid: bid, totalDice: totalDice)
        let percentage = Int(round(probability * 100))
        return "\(percentage)%"
    }
    
    /// Get color for probability based on thresholds
    func getProbabilityColor(bid: Int, totalDice: Int) -> Color {
        let probability = getProbability(bid: bid, totalDice: totalDice)
        return getColorForProbability(probability)
    }
    
    /// Clear the probability cache
    func clearCache() {
        cache.removeAll()
    }
    
    // MARK: - Private Methods
    
    /// Calculate binomial probability P(X ≥ k) where X ~ Binomial(n, p)
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
    
    /// Calculate binomial coefficient C(n, k) using logarithms to avoid overflow
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
    let bid: Int
    let totalDice: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bid)
        hasher.combine(totalDice)
    }
}