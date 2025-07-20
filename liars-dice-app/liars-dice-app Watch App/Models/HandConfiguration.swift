//
//  HandConfiguration.swift
//  liars-dice-app Watch App
//
//  Model for storing and managing the player's hand configuration for Screen 3
//

import Foundation

struct HandConfiguration {
    let diceCount: Int
    private(set) var faceValues: [Int?]
    var bidFace: Int {
        didSet {
            guard bidFace >= 1 && bidFace <= 6 else {
                bidFace = oldValue
                return
            }
        }
    }
    
    // MARK: - Initialization
    
    init(diceCount: Int, bidFace: Int = 1) {
        guard diceCount > 0 else {
            fatalError("Dice count must be positive")
        }
        
        self.diceCount = diceCount
        self.faceValues = Array(repeating: nil, count: diceCount)
        self.bidFace = max(1, min(6, bidFace))
    }
    
    // MARK: - Public Methods
    
    /// Set the face value for a specific die
    /// - Parameters:
    ///   - index: Die index (0-based)
    ///   - value: Face value (1-6) or nil to clear
    /// - Returns: True if successful, false if invalid parameters
    @discardableResult
    mutating func setDie(at index: Int, to value: Int?) -> Bool {
        guard index >= 0 && index < diceCount else { return false }
        
        if let value = value {
            guard value >= 1 && value <= 6 else { return false }
        }
        
        faceValues[index] = value
        return true
    }
    
    /// Get the face value for a specific die
    /// - Parameter index: Die index (0-based)
    /// - Returns: Face value (1-6) or nil if unset/invalid index
    func getDie(at index: Int) -> Int? {
        guard index >= 0 && index < diceCount else { return nil }
        return faceValues[index]
    }
    
    /// Count how many dice show the specified face
    /// - Parameter face: Face value to count (1-6)
    /// - Returns: Number of dice showing this face, 0 if invalid face
    func countMatching(face: Int) -> Int {
        guard face >= 1 && face <= 6 else { return 0 }
        return faceValues.compactMap { $0 }.filter { $0 == face }.count
    }
    
    /// Count how many dice show the current bid face
    /// - Returns: Number of dice showing the bid face
    func countMatchingBidFace() -> Int {
        return countMatching(face: bidFace)
    }
    
    /// Check if all dice have been set
    /// - Returns: True if all dice have face values
    func isComplete() -> Bool {
        return faceValues.allSatisfy { $0 != nil }
    }
    
    /// Check if any dice have been set
    /// - Returns: True if at least one die has a face value
    func hasAnyDiceSet() -> Bool {
        return faceValues.contains { $0 != nil }
    }
    
    /// Get count of dice that have been set
    /// - Returns: Number of dice with face values
    func setDiceCount() -> Int {
        return faceValues.compactMap { $0 }.count
    }
    
    /// Reset all dice to unset state
    mutating func reset() {
        faceValues = Array(repeating: nil, count: diceCount)
    }
    
    /// Reset a specific die to unset state
    /// - Parameter index: Die index to reset
    /// - Returns: True if successful, false if invalid index
    @discardableResult
    mutating func resetDie(at index: Int) -> Bool {
        return setDie(at: index, to: nil)
    }
    
    /// Set multiple dice to the same value
    /// - Parameters:
    ///   - indices: Array of die indices to set
    ///   - value: Face value to set (1-6) or nil to clear
    /// - Returns: True if all dice were set successfully
    @discardableResult
    mutating func setDice(at indices: [Int], to value: Int?) -> Bool {
        var success = true
        for index in indices {
            if !setDie(at: index, to: value) {
                success = false
            }
        }
        return success
    }
    
    /// Get summary of current hand state
    /// - Returns: String describing the hand (e.g., "2 fives, 1 three")
    func handSummary() -> String {
        let setCounts = (1...6).compactMap { face in
            let count = countMatching(face: face)
            return count > 0 ? "\(count) \(face == 1 ? "one" : face == 2 ? "two" : face == 3 ? "three" : face == 4 ? "four" : face == 5 ? "five" : "six")\(count > 1 ? "s" : "")" : nil
        }
        
        if setCounts.isEmpty {
            return "No dice set"
        }
        
        return setCounts.joined(separator: ", ")
    }
}

// MARK: - Equatable

extension HandConfiguration: Equatable {
    static func == (lhs: HandConfiguration, rhs: HandConfiguration) -> Bool {
        return lhs.diceCount == rhs.diceCount &&
               lhs.faceValues == rhs.faceValues &&
               lhs.bidFace == rhs.bidFace
    }
}

// MARK: - Codable

extension HandConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case diceCount
        case faceValues
        case bidFace
    }
}