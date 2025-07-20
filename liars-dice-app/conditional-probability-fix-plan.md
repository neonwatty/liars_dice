# Conditional Probability Engine Fix Plan

## UPDATE: Debug Investigation Complete

### Key Findings
1. The conditional probability logic is mathematically correct
2. The issue appears to be a UI state management problem
3. Added extensive debug logging throughout the system

### Debug Logging Added
- ConditionalProbabilityEngine: Logs all inputs and calculations
- HandConfiguration: Logs when dice are set and counted
- HandEntryView: Logs UI interactions and state changes
- GameState: Logs bid face updates and probability calculations

## Problem Analysis

### Current Issue
- User reports: With 10 total dice, bid count of 3, bid face of 1 (ones), and 3 dice all showing 1s, the app shows 72% instead of 100%
- The conditional probability calculation appears to have a bug

### How the App Should Work
1. **Screen 2**: User selects bid COUNT (e.g., 6) - probability shown is for "6 dice of ANY face"
2. **Screen 3**: User selects:
   - Their dice count (e.g., 3)
   - The bid FACE (e.g., 3 for "threes") 
   - Their actual dice values
   - Result: Shows probability of "6 threes" given known dice

### The Bug
The current ConditionalProbabilityEngine should be calculating:
- P(at least k dice show specific face f | player's known dice showing various faces)

But something is wrong with the calculation when the player already has enough matching dice.

## Root Cause Investigation

Looking at the code in ConditionalProbabilityEngine.swift:
```swift
// Get count of player's dice showing the bid face
let myMatchingDice = handConfig.countMatchingBidFace()

// Calculate remaining dice needed and unknown dice count
let remainingNeeded = bid - myMatchingDice
let unknownDice = totalDice - handConfig.diceCount

// If we already have enough matching dice, probability is 100%
if remainingNeeded <= 0 {
    return 1.0
}
```

This logic looks correct! If the user has 3 dice all showing 1s, and the bid is for 3 ones:
- myMatchingDice = 3
- remainingNeeded = 3 - 3 = 0
- Should return 1.0 (100%)

## Hypothesis

The issue might be:
1. The bid face is not being set correctly in HandConfiguration
2. The countMatchingBidFace() method is not counting correctly
3. The dice values are not being set properly in the UI

## Debugging Steps

### Step 1: Verify HandConfiguration bid face
Check if the bid face selector in Screen 3 is properly updating the HandConfiguration

### Step 2: Verify dice counting
Check if countMatchingBidFace() correctly counts dice matching the bid face

### Step 3: Verify dice value setting
Check if the UI is properly setting dice values when the user selects them

## Fix Implementation Plan

### Task 1: Add Debug Logging
Add logging to track:
- What bid face is selected
- What dice values are set
- What countMatchingBidFace() returns
- What the conditional probability calculation returns

### Task 2: Fix Any Issues Found
Based on the logging, fix the specific issue causing the incorrect calculation

### Task 3: Add Unit Tests
Add specific test cases for:
- User has exactly k dice of bid face → 100%
- User has more than k dice of bid face → 100%
- User has some but not enough → correct partial probability
- User has none → correct probability based on unknown dice

## Test Cases

### Test Case 1: User's Reported Issue
- Total dice: 10
- Bid count: 3 (from Screen 2)
- Bid face: 1 (ones, selected on Screen 3)
- Player's dice: 3 dice all showing 1s
- Expected: 100% (player already has 3 ones)

### Test Case 2: Partial Match
- Total dice: 10
- Bid count: 5
- Bid face: 2 (twos)
- Player's dice: 3 dice (2 showing twos, 1 showing three)
- Expected: P(at least 3 more twos among 7 unknown dice)

### Test Case 3: No Matches
- Total dice: 10
- Bid count: 4
- Bid face: 6 (sixes)
- Player's dice: 3 dice (none showing sixes)
- Expected: P(at least 4 sixes among 7 unknown dice)

## Implementation Tasks

- [ ] Add debug logging to ConditionalProbabilityEngine
- [ ] Add debug logging to HandConfiguration
- [ ] Add debug logging to HandEntryView for dice value updates
- [ ] Test the reported scenario and check logs
- [ ] Fix the identified issue
- [ ] Add comprehensive unit tests
- [ ] Remove debug logging after fix is verified