# Efficient Algorithms for Binomial Probability Calculations in Liar's Dice

## Overview

For Liar's Dice, we need to calculate the cumulative binomial probability:

**P(k|n) = ∑ₓ₌ₖⁿ C(n,x)(1/6)ˣ(5/6)ⁿ⁻ˣ**

Where:
- n = total number of dice in play (1 ≤ n ≤ 40)
- k = the bid (number of dice showing a specific face value)
- p = 1/6 (probability of rolling any specific face)
- q = 5/6 (probability of not rolling that face)

## Algorithm Comparison

### 1. Direct Calculation Method

**Pros:**
- Straightforward implementation
- Good for small n values
- No memory overhead

**Cons:**
- Computationally expensive for large n
- Risk of overflow with factorials
- O(n²) time complexity per calculation

```swift
// Direct calculation - NOT RECOMMENDED for n > 20
func binomialCoefficientDirect(_ n: Int, _ k: Int) -> Double {
    if k > n || k < 0 { return 0 }
    if k == 0 || k == n { return 1 }
    
    // Using factorial would overflow for large n
    return factorial(n) / (factorial(k) * factorial(n - k))
}
```

### 2. Optimized Iterative Calculation

**Pros:**
- Avoids factorial overflow
- More efficient than direct method
- O(k) time complexity

**Cons:**
- Still needs computation for each query
- Precision issues with floating point for large n

```swift
// Optimized binomial coefficient calculation
func binomialCoefficient(_ n: Int, _ k: Int) -> Double {
    if k > n || k < 0 { return 0 }
    if k == 0 || k == n { return 1 }
    
    var k = k
    if k > n - k { k = n - k } // Take advantage of symmetry
    
    var result: Double = 1
    for i in 0..<k {
        result *= Double(n - i)
        result /= Double(i + 1)
    }
    
    return result
}
```

### 3. Logarithmic Calculation (Recommended for Computation)

**Pros:**
- Avoids overflow completely
- Better numerical stability
- Can handle large n values

**Cons:**
- Slightly more complex
- Still requires computation per query

```swift
// Logarithmic approach for numerical stability
func logBinomialCoefficient(_ n: Int, _ k: Int) -> Double {
    if k > n || k < 0 { return -Double.infinity }
    if k == 0 || k == n { return 0 }
    
    var k = k
    if k > n - k { k = n - k }
    
    var logResult: Double = 0
    for i in 0..<k {
        logResult += log(Double(n - i))
        logResult -= log(Double(i + 1))
    }
    
    return logResult
}

func binomialProbabilityLog(_ n: Int, _ k: Int, _ p: Double) -> Double {
    let logBinom = logBinomialCoefficient(n, k)
    let logProb = logBinom + Double(k) * log(p) + Double(n - k) * log(1 - p)
    return exp(logProb)
}
```

### 4. Precomputed Lookup Table (Recommended for Production)

**Pros:**
- O(1) lookup time
- No runtime computation
- Guaranteed <50ms response time
- No precision issues

**Cons:**
- Memory usage (~13KB for our requirements)
- Initial computation/loading time

```swift
class ProbabilityLookupTable {
    private var table: [[Double]] = []
    private let maxDice = 40
    private let p: Double = 1.0 / 6.0
    
    init() {
        precomputeTable()
    }
    
    private func precomputeTable() {
        table = Array(repeating: Array(repeating: 0.0, count: maxDice + 1), 
                      count: maxDice + 1)
        
        for n in 1...maxDice {
            for k in 0...n {
                table[n][k] = computeCumulativeProbability(n: n, k: k)
            }
        }
    }
    
    private func computeCumulativeProbability(n: Int, k: Int) -> Double {
        var cumulative: Double = 0
        
        for x in k...n {
            let logProb = logBinomialCoefficient(n, x) + 
                         Double(x) * log(p) + 
                         Double(n - x) * log(1 - p)
            cumulative += exp(logProb)
        }
        
        return cumulative
    }
    
    func getProbability(n: Int, k: Int) -> Double {
        guard n >= 1 && n <= maxDice && k >= 0 && k <= n else { return 0 }
        return table[n][k]
    }
}
```

## Swift's Accelerate Framework Analysis

The Accelerate framework provides highly optimized mathematical functions but has limitations for our use case:

### Available Functions:
- `vDSP` for vector operations
- `vForce` for transcendental functions (log, exp)
- No direct binomial distribution functions

### Potential Usage:

```swift
import Accelerate

// Vectorized logarithm calculation for batch processing
func computeLogFactorials(upTo n: Int) -> [Double] {
    var logFactorials = [Double](repeating: 0, count: n + 1)
    var values = (1...n).map { Double($0) }
    
    // Compute log of 1 to n
    var logValues = [Double](repeating: 0, count: n)
    vForce.log(&logValues, &values, [Int32(n)])
    
    // Cumulative sum for log factorials
    logFactorials[0] = 0
    for i in 1...n {
        logFactorials[i] = logFactorials[i-1] + logValues[i-1]
    }
    
    return logFactorials
}
```

### Recommendation:
While Accelerate can optimize batch computations, for our use case with a lookup table, the initial computation time is not critical. The framework would be more beneficial if we were doing real-time calculations.

## Edge Cases Handling

### 1. Small n (n < 6)

These cases are mathematically valid and should be handled normally:

```swift
// Edge case examples:
// n=1, k=0: P = (5/6)¹ = 0.833...
// n=1, k=1: P = (1/6)¹ = 0.166...
// n=2, k=0: P = (5/6)² + 2×(1/6)×(5/6) + (1/6)² = 1.0
// n=2, k=1: P = 2×(1/6)×(5/6) + (1/6)² = 0.305...
// n=2, k=2: P = (1/6)² = 0.0277...
```

### 2. Boundary Conditions

```swift
func validateInput(n: Int, k: Int) -> Bool {
    return n >= 1 && n <= 40 && k >= 0 && k <= n
}

// Special cases:
// k = 0: Always probability 1.0 (at least 0 dice showing the value)
// k = n: Probability of all dice showing the same value
// k > n: Impossible, probability 0.0
```

## Implementation Plan

### 1. Core Probability Engine Structure

```swift
// File: Models/ProbabilityEngine.swift

import Foundation

class ProbabilityEngine {
    static let shared = ProbabilityEngine()
    
    private let lookupTable: ProbabilityLookupTable
    private let maxDice = 40
    
    private init() {
        self.lookupTable = ProbabilityLookupTable()
    }
    
    /// Get probability of at least k dice showing a specific value out of n total dice
    func getProbability(totalDice n: Int, bid k: Int) -> Double {
        return lookupTable.getProbability(n: n, k: k)
    }
    
    /// Find the break-even bid (highest k where P(k|n) >= 0.5)
    func getBreakEvenBid(totalDice n: Int) -> Int {
        guard n >= 1 && n <= maxDice else { return 0 }
        
        // Binary search for efficiency
        var left = 0
        var right = n
        var result = 0
        
        while left <= right {
            let mid = (left + right) / 2
            let probability = getProbability(totalDice: n, bid: mid)
            
            if probability >= 0.5 {
                result = mid
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        return result
    }
    
    /// Get color for probability display
    func getColorForProbability(_ probability: Double) -> ProbabilityColor {
        switch probability {
        case 0.5...1.0:
            return .green
        case 0.3..<0.5:
            return .yellow
        default:
            return .red
        }
    }
}

enum ProbabilityColor {
    case green  // P >= 50%
    case yellow // 30% <= P < 50%
    case red    // P < 30%
}
```

### 2. Optimized Lookup Table Implementation

```swift
// File: Models/ProbabilityLookupTable.swift

import Foundation

class ProbabilityLookupTable {
    private var table: [Double] = []
    private let maxDice = 40
    private let p: Double = 1.0 / 6.0
    
    init() {
        precomputeTable()
    }
    
    // Flatten 2D array to 1D for memory efficiency
    private func getIndex(n: Int, k: Int) -> Int {
        // Sum of arithmetic series for offset + k
        return (n * (n - 1)) / 2 + n + k
    }
    
    private func precomputeTable() {
        // Total elements: sum from 1 to 40 of (n+1) = 861 elements
        let totalElements = (maxDice * (maxDice + 1)) / 2 + maxDice + 1
        table = Array(repeating: 0.0, count: totalElements)
        
        // Precompute log factorials for efficiency
        let logFactorials = computeLogFactorials(upTo: maxDice)
        
        for n in 1...maxDice {
            for k in 0...n {
                let probability = computeCumulativeProbability(
                    n: n, k: k, logFactorials: logFactorials
                )
                table[getIndex(n: n, k: k)] = probability
            }
        }
    }
    
    private func computeLogFactorials(upTo n: Int) -> [Double] {
        var logFactorials = [Double](repeating: 0, count: n + 1)
        logFactorials[0] = 0
        
        for i in 1...n {
            logFactorials[i] = logFactorials[i-1] + log(Double(i))
        }
        
        return logFactorials
    }
    
    private func computeCumulativeProbability(n: Int, k: Int, 
                                            logFactorials: [Double]) -> Double {
        var cumulative: Double = 0
        let logP = log(p)
        let logQ = log(1 - p)
        
        for x in k...n {
            let logBinom = logFactorials[n] - logFactorials[x] - logFactorials[n-x]
            let logProb = logBinom + Double(x) * logP + Double(n - x) * logQ
            cumulative += exp(logProb)
        }
        
        return cumulative
    }
    
    func getProbability(n: Int, k: Int) -> Double {
        guard n >= 1 && n <= maxDice && k >= 0 && k <= n else {
            return k == 0 ? 1.0 : 0.0  // k=0 always has probability 1
        }
        return table[getIndex(n: n, k: k)]
    }
}
```

### 3. Memory Usage Calculation

```
Total probability values: ∑(n+1) for n=1 to 40 = 861 values
Memory per Double: 8 bytes
Total memory: 861 × 8 = 6,888 bytes ≈ 6.7 KB

Additional overhead:
- Class instance: ~100 bytes
- Array metadata: ~100 bytes
- Total: < 7 KB (well under 50 KB requirement)
```

### 4. Performance Optimization Tips

1. **Use singleton pattern** for ProbabilityEngine to avoid multiple instances
2. **Precompute on app launch** in background queue if needed
3. **Use integer math** where possible for array indexing
4. **Cache break-even values** if repeatedly queried

```swift
// Example of caching break-even values
class ProbabilityEngine {
    private var breakEvenCache: [Int: Int] = [:]
    
    func getBreakEvenBid(totalDice n: Int) -> Int {
        if let cached = breakEvenCache[n] {
            return cached
        }
        
        let breakEven = calculateBreakEven(n: n)
        breakEvenCache[n] = breakEven
        return breakEven
    }
}
```

## Testing Strategy

```swift
// File: Tests/ProbabilityEngineTests.swift

import XCTest

class ProbabilityEngineTests: XCTestCase {
    let engine = ProbabilityEngine.shared
    
    func testEdgeCases() {
        // n=1 cases
        XCTAssertEqual(engine.getProbability(totalDice: 1, bid: 0), 1.0, accuracy: 0.0001)
        XCTAssertEqual(engine.getProbability(totalDice: 1, bid: 1), 1.0/6.0, accuracy: 0.0001)
        
        // Impossible cases
        XCTAssertEqual(engine.getProbability(totalDice: 5, bid: 6), 0.0)
        
        // Boundary cases
        XCTAssertEqual(engine.getProbability(totalDice: 40, bid: 0), 1.0)
    }
    
    func testKnownValues() {
        // n=6, k=1: Should be close to 0.665
        XCTAssertEqual(engine.getProbability(totalDice: 6, bid: 1), 0.665, accuracy: 0.001)
        
        // n=10, k=2: Should be close to 0.515
        XCTAssertEqual(engine.getProbability(totalDice: 10, bid: 2), 0.515, accuracy: 0.001)
    }
    
    func testBreakEven() {
        // For n=6, break-even should be k=1
        XCTAssertEqual(engine.getBreakEvenBid(totalDice: 6), 1)
        
        // For n=12, break-even should be k=2
        XCTAssertEqual(engine.getBreakEvenBid(totalDice: 12), 2)
    }
    
    func testPerformance() {
        measure {
            // Should complete in < 0.001 seconds
            for n in 1...40 {
                for k in 0...n {
                    _ = engine.getProbability(totalDice: n, bid: k)
                }
            }
        }
    }
}
```

## Summary of Recommendations

1. **Use precomputed lookup table** for production (O(1) lookup, <7KB memory)
2. **Implement with logarithmic calculations** to avoid overflow
3. **Flatten 2D array to 1D** for memory efficiency
4. **Cache break-even values** for repeated queries
5. **Handle edge cases explicitly** in validation
6. **Test thoroughly** with known probability values
7. **Consider Accelerate framework** only if doing batch real-time calculations

This approach ensures:
- Response time < 50ms (actually < 1ms with lookup)
- Memory usage < 50KB (actual: ~7KB)
- Numerical stability for all valid inputs
- Correct handling of all edge cases