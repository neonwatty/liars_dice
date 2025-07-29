# Liars' Dice Probability Watch App – Screen 3 PRD (Updated)

## 1. Overview

**Purpose**  
Add confirmed-hand input capability to provide more accurate probability calculations by incorporating the player's known dice into the probability computation.

**Goals**
- Individual die entry with Crown and voice input
- Completely separate probability engine to avoid affecting Screen 2
- Clear visual comparison of probabilities
- Maintain app simplicity and speed

---

## 2. Screen Design

### Screen 3 – Hand Entry

**Trigger**: Activated only when "My Dice" count > 0 on Screen 2

**Layout**:
- Header: `Enter Your Hand`
- Sub-header: `Bid Face: [1-6]` (adjustable selector)
- Main area: Grid of N dice icons (N = My Dice count)
  - Each die shows current face value (1-6 or blank)
  - Selected die has highlight border
  - Tap to select different die
  - Crown adjusts selected die's face value
- Bottom section:
  - Probability comparison display:
    - `Original: X%` (from Screen 2)
    - `With Hand: Y%` (updated calculation)
    - Visual arrow indicating change (↑/↓)
- Navigation: Left-arrow icon → return to Screen 2

---

## 3. Interaction Design

### Manual Input
1. Tap die to select it (highlight border appears)
2. Rotate Crown to set face value (1-6)
3. Tap next die or use swipe gesture to move between dice
4. Values persist until changed or cleared

### Voice Input
1. Tap microphone icon or long-press any die
2. System listens for commands:
   - Single die: "five" or "show five" → sets selected die to 5
   - Multiple dice: "three fives" → sets next 3 unset dice to 5
   - Specific positions: "first die four" → sets first die to 4
3. Visual feedback during recognition
4. Error recovery with clear error messages

### Bid Face Selection
- Separate selector at top of screen
- Tap to cycle through faces 1-6
- Or use dedicated Crown focus mode
- This determines which face we're calculating probability for

---

## 4. Conditional Probability Engine

### Separate Implementation
Create `ConditionalProbabilityEngine.swift` - completely independent from existing `ProbabilityEngine.swift`

### Calculation Method
Given:
- `n_total` = total dice in play
- `n_mine` = my dice count  
- `k` = bid count
- `f` = bid face (1-6)
- `h_f` = count of my dice showing face f

Calculate:
- `k_remaining = k - h_f` (remaining dice needed)
- `n_unknown = n_total - n_mine` (other players' dice)

If `k_remaining ≤ 0`: **P = 100%**  
Else: **P = Σ(x=k_remaining to n_unknown) C(n_unknown, x) × (1/6)^x × (5/6)^(n_unknown-x)**

### Performance
- No lookup table needed (calculations are simple)
- Real-time computation as hand values change
- Cache results for unchanged inputs

---

## 5. State Management

### Hand Configuration Model
```swift
struct HandConfiguration {
    let diceCount: Int
    var faceValues: [Int?] // nil for unset dice
    var bidFace: Int
    
    func countMatching(face: Int) -> Int
    func isComplete() -> Bool
    func reset()
}
```

### State Rules
1. Hand configuration cleared when:
   - Total dice count changes
   - My dice count changes
   - User navigates away from Screen 3
2. Configuration persists during:
   - Navigation between Screen 2 and 3
   - Bid value adjustments on Screen 2

---

## 6. Voice Recognition

### Implementation
- Use on-device `SFSpeechRecognizer`
- Custom vocabulary for dice-specific commands
- No network dependency

### Command Patterns
- Simple: "[number]" → sets selected die
- Count-based: "[count] [face]s" → sets multiple dice
- Positional: "[position] die [face]" → sets specific die
- Clear: "clear" or "reset" → clears selected/all dice

### Feedback
- Visual waveform during listening
- Haptic feedback on successful recognition
- Clear error messages for unrecognized commands

---

## 7. Visual Design

### Dice Display
- 2x3 or 3x2 grid layout (adapts to dice count)
- Die face shows dots pattern (like physical dice)
- Empty die shows question mark or dashed border
- Selected die has colored border
- Smooth animations for value changes

### Probability Comparison
- Side-by-side percentage display
- Color coding maintained (green/yellow/red)
- Arrow indicator for improvement/degradation
- Difference value shown (e.g., "+15%")

### Accessibility
- VoiceOver support for all elements
- Dice values announced clearly
- Probability changes announced
- High contrast mode support

---

## 8. Navigation Flow

1. Screen 2: User sets "My Dice" > 0
2. New button appears: "Enter Hand" or dice icon
3. Tap button → navigate to Screen 3
4. Enter hand via Crown/voice
5. See updated probability in real-time
6. Tap back arrow → return to Screen 2
7. Screen 2 shows original probability (unchanged)

---

## 9. Edge Cases

- `k_remaining ≤ 0` → Display "100% (Guaranteed)"
- All dice entered → Disable unneeded UI elements
- Voice recognition fails → Show manual input hint
- Invalid voice command → Gentle error message
- Bid face not selected → Default to face 1

---

## 10. Technical Notes

- Screen 3 is optional - app remains fully functional without it
- No modifications to existing ProbabilityEngine
- ConditionalProbabilityEngine is self-contained
- Voice recognition is optional enhancement
- All calculations complete in <50ms

---

## Summary

Screen 3 enhances the app for serious players by incorporating known dice into probability calculations. The separate probability engine ensures existing functionality remains stable while adding this advanced feature. Individual die entry with voice support provides both precision and speed for real gameplay scenarios.