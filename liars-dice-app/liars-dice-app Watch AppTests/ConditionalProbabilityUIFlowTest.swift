//
//  ConditionalProbabilityUIFlowTest.swift
//  liars-dice-app Watch AppTests
//
//  Test that simulates the exact UI flow to debug conditional probability
//

import XCTest
@testable import liars_dice_app_Watch_App

class ConditionalProbabilityUIFlowTest: XCTestCase {
    
    func testCompleteUIFlow() {
        print("\n=== SIMULATING COMPLETE UI FLOW ===")
        
        // 1. Create GameState as it would be on app launch
        let gameState = GameState()
        
        // 2. User sets total dice to 10 on Screen 1
        gameState.updateTotalDice(10)
        print("Screen 1: Total dice set to \(gameState.totalDiceCount)")
        
        // 3. User sets bid to 3 on Screen 2
        gameState.updateCurrentBid(3)
        print("Screen 2: Bid set to \(gameState.currentBid)")
        
        // 4. User navigates to Screen 3
        print("\nNavigating to Screen 3...")
        
        // 5. User sets their dice count to 3
        gameState.updateMyDiceCount(3)
        print("Screen 3: My dice count set to \(gameState.myDiceCount)")
        
        // 6. Initialize hand configuration (happens in onAppear)
        gameState.initializeHandConfiguration() // Default bidFace = 1
        print("Screen 3: Hand configuration initialized")
        
        if let config = gameState.handConfiguration {
            print("  - Initial bid face: \(config.bidFace)")
        }
        
        // 7. User updates bid face (if different from default)
        // In this case, user wants "ones" which is already 1, so no change needed
        
        // 8. User sets all 3 dice to show 1s
        print("\nSetting dice values...")
        gameState.updateHandDie(at: 0, to: 1)
        gameState.updateHandDie(at: 1, to: 1)
        gameState.updateHandDie(at: 2, to: 1)
        
        // 9. Check final state
        print("\n=== FINAL STATE ===")
        print("Total dice: \(gameState.totalDiceCount)")
        print("Current bid: \(gameState.currentBid)")
        print("My dice count: \(gameState.myDiceCount)")
        
        if let config = gameState.handConfiguration {
            print("Bid face: \(config.bidFace)")
            print("Dice values: \(config.faceValues)")
            print("Matching dice: \(config.countMatchingBidFace())")
        }
        
        print("\nConditional probability: \(gameState.conditionalProbability)")
        print("Conditional probability %: \(gameState.conditionalProbabilityPercentage)")
        
        // Verify the result
        XCTAssertEqual(gameState.conditionalProbability, 1.0, accuracy: 0.001, 
                      "Should be 100% when player has 3 ones and bid is 3")
    }
    
    func testUIFlowWithDifferentBidFace() {
        print("\n=== TEST WITH DIFFERENT BID FACE ===")
        
        let gameState = GameState()
        gameState.updateTotalDice(10)
        gameState.updateCurrentBid(3)
        gameState.updateMyDiceCount(3)
        gameState.initializeHandConfiguration()
        
        // User changes bid face to 6 (sixes)
        gameState.updateHandBidFace(6)
        
        // User sets all dice to 6s
        gameState.updateHandDie(at: 0, to: 6)
        gameState.updateHandDie(at: 1, to: 6)
        gameState.updateHandDie(at: 2, to: 6)
        
        print("Bid face: \(gameState.handConfiguration?.bidFace ?? -1)")
        print("Conditional probability: \(gameState.conditionalProbabilityPercentage)")
        
        XCTAssertEqual(gameState.conditionalProbability, 1.0, accuracy: 0.001,
                      "Should be 100% when player has 3 sixes and bid is 3 sixes")
    }
}