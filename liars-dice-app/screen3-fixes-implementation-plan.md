# Screen 3 Fixes Implementation Plan

## Overview
Two critical bugs need to be fixed:
1. Conditional probability incorrectly decreases when revealing matching dice
2. Cannot select dice on initial entry to Screen 3

## Issue 1: Conditional Probability Calculation Bug

### Current Problem
The system treats ALL of the player's dice as "known" even when they haven't been set, causing incorrect probability calculations.

**Example Scenario:**
- Total dice in game: 10
- Current bid: 3 ones
- Player has: 3 dice
- Player sets: 1 die to show a one

**Current (Incorrect) Behavior:**
- Counts 1 matching die ✓
- Calculates unknown dice as: 10 - 3 = 7 ✗ (treats all 3 player dice as known)
- Calculates P(≥2 ones in 7 dice) → Lower probability

**Expected (Correct) Behavior:**
- Counts 1 matching die ✓
- Calculates unknown dice as: 10 - 1 = 9 ✓ (only set dice are known)
- Calculates P(≥2 ones in 9 dice) → Higher probability

### Root Cause
In `ConditionalProbabilityEngine.swift` line 41:
```swift
let unknownDice = totalDice - handConfig.diceCount
```
This uses `diceCount` (total player dice) instead of `setDiceCount()` (actually revealed dice).

### Solution
Change line 41 to:
```swift
let unknownDice = totalDice - handConfig.setDiceCount()
```

### Why This Works
- Only dice that have been explicitly set (revealed) are removed from the unknown pool
- Unset dice remain part of the probability calculation
- Revealing matching dice increases probability (fewer unknowns needed)
- Revealing non-matching dice decreases probability (fewer chances in unknown pool)

## Issue 2: Die Selection Bug on Initial Entry

### Current Problem
Cannot tap/select dice when first entering Screen 3. Must go back to Screen 2 and re-enter.

### Root Cause
In `HandEntryView.swift` `setupInitialState()`:
1. Calls `selectFirstAvailableDie()` (line 311)
2. But `handConfiguration` is still nil at this point
3. `selectFirstAvailableDie()` returns early due to guard statement (line 327)
4. Hand configuration is initialized AFTER (lines 306-308)
5. Die selection is never set up properly

### Solution
Reorder the initialization to ensure hand configuration exists before selecting die:

```swift
private func setupInitialState() {
    // Start with my dice count mode
    crownMode = .myDiceCount
    crownValue = Double(gameState.myDiceCount)
    
    // Initialize hand configuration if we have dice
    if gameState.myDiceCount > 0 && gameState.handConfiguration == nil {
        gameState.initializeHandConfiguration()
    }
    
    // NOW select first die (after config exists)
    selectFirstAvailableDie()
}
```

## Implementation Steps

### Step 1: Fix Conditional Probability Engine ✅ COMPLETED
1. Open `ConditionalProbabilityEngine.swift`
2. Locate line 41 in `getConditionalProbability` method
3. Change:
   ```swift
   let unknownDice = totalDice - handConfig.diceCount
   ```
   To:
   ```swift
   let unknownDice = totalDice - handConfig.setDiceCount()
   ```

### Step 2: Fix Die Selection ✅ COMPLETED
1. Open `HandEntryView.swift`
2. Locate `setupInitialState()` method (around line 305)
3. Move `selectFirstAvailableDie()` to after hand configuration initialization

### Step 3: Testing
1. Build and run the app
2. Test probability calculation:
   - Set total dice to 10
   - Set bid to 3 ones
   - Go to Screen 3, set my dice to 3
   - Set 1 die to one → probability should increase
   - Set another die to non-one → probability should decrease slightly
   - Leave third die unset → should not affect probability
3. Test die selection:
   - Enter Screen 3 directly
   - Should be able to tap dice immediately
   - Crown should control die values without needing to exit/re-enter

## Expected Results
- Revealing matching dice increases win probability
- Revealing non-matching dice decreases win probability  
- Unset dice don't affect calculations
- Die selection works immediately on Screen 3 entry

## Notes
- The fix is minimal - only 1 line change in each file
- No changes to the mathematical formulas needed
- The existing `setDiceCount()` method already provides what we need

## Status: ✅ COMPLETED
- Both fixes have been implemented
- App builds successfully without errors
- Ready for testing