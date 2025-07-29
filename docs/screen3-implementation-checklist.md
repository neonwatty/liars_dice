# Screen 3 Implementation Checklist

## Overview
This checklist tracks the implementation of Screen 3 (Confirmed Hand Entry) for the Liar's Dice Probability Watch App. It will be updated as progress is made.

**Key Constraint**: No modifications to existing ProbabilityEngine.swift - all new calculations use separate ConditionalProbabilityEngine.swift

---

## Phase 1: Core Infrastructure ✅

### Models and Data Structures
- [x] Create `HandConfiguration.swift` model
  - [x] Properties: diceCount, faceValues array, bidFace
  - [x] Methods: countMatching(face:), isComplete(), reset()
  - [x] Validation logic for face values (1-6 or nil)
  - [x] Unit tests for model

### Probability Engine
- [x] Create `ConditionalProbabilityEngine.swift`
  - [x] Implement conditional probability calculation
  - [x] Add caching for performance
  - [x] Create comprehensive unit tests
  - [x] Benchmark performance (<50ms requirement)
  - [x] Document calculation method

### State Management
- [x] Extend GameState with hand configuration
  - [x] Add @Published handConfiguration property
  - [x] Add methods to update hand configuration
  - [x] Implement reset logic for upstream changes
  - [x] Add navigation state for Screen 3

---

## Phase 2: Basic UI Implementation ✅

### HandEntryView
- [x] Create `HandEntryView.swift`
  - [x] Implement basic layout with dice grid
  - [x] Add bid face selector UI
  - [x] Create die selection highlighting
  - [x] Add navigation (back arrow)
  - [x] Implement probability comparison display

### Dice Display Components
- [x] Create custom `DieView` component
  - [x] Visual representation of die faces (1-6)
  - [x] Empty state display
  - [x] Selection state with border
  - [x] Smooth animations
  - [x] Accessibility labels

### Digital Crown Integration
- [x] Implement Crown control for selected die
  - [x] Value adjustment (1-6)
  - [x] Haptic feedback
  - [x] Focus management
  - [x] Handle bid face selector mode

---

## Phase 3: Navigation and Integration ✅

### Navigation Flow
- [x] Add "Enter Hand" button to Screen 2
  - [x] Show only when My Dice > 0
  - [x] Appropriate icon/label
  - [x] Accessibility support
  
- [x] Implement navigation to Screen 3
  - [x] Pass necessary state
  - [x] Smooth transition animation
  - [x] Preserve hand configuration during navigation

- [x] Update navigation from Screen 3 to Screen 2
  - [x] Maintain hand configuration
  - [x] No modification to Screen 2 probability display

### State Synchronization
- [x] Implement configuration reset logic
  - [x] Clear on total dice change
  - [x] Clear on my dice count change
  - [x] Preserve during bid adjustments
  - [x] Test state consistency

---

## Phase 4: Probability Display ✅

### Visual Comparison
- [x] Create probability comparison component
  - [x] Original probability display
  - [x] Conditional probability display
  - [x] Difference indicator (arrow + percentage)
  - [x] Color coding consistency

### Real-time Updates
- [x] Connect UI to ConditionalProbabilityEngine
  - [x] Update on each die value change
  - [x] Update on bid face change
  - [x] Performance optimization
  - [x] Loading states if needed

---

## Phase 5: Voice Input ⏳

### Speech Recognition Setup
- [ ] Create `VoiceInputHandler.swift`
  - [ ] Configure SFSpeechRecognizer
  - [ ] Define custom vocabulary
  - [ ] Implement command parser
  - [ ] Error handling

### Voice Command Support
- [ ] Implement command patterns
  - [ ] Simple number commands
  - [ ] Count-based commands ("three fives")
  - [ ] Position-based commands
  - [ ] Clear/reset commands

### UI Integration
- [ ] Add microphone button
  - [ ] Visual feedback during recognition
  - [ ] Waveform or listening indicator
  - [ ] Error state display
  - [ ] Accessibility considerations

### Voice Feedback
- [ ] Implement recognition feedback
  - [ ] Haptic feedback on success
  - [ ] Visual confirmation
  - [ ] Error messages
  - [ ] Retry mechanisms

---

## Phase 6: Polish and Edge Cases ⏳

### Visual Polish
- [ ] Refine animations
  - [ ] Die value changes
  - [ ] Selection transitions
  - [ ] Navigation animations
  - [ ] Loading states

### Edge Case Handling
- [ ] Handle guaranteed probability (k ≤ h_f)
- [ ] Handle all dice entered state
- [ ] Handle voice recognition failures
- [ ] Handle rapid navigation
- [ ] Handle app backgrounding

### Accessibility
- [ ] Complete VoiceOver support
  - [ ] All interactive elements labeled
  - [ ] Value changes announced
  - [ ] Navigation hints
  - [ ] Probability changes announced

- [ ] Dynamic Type support
- [ ] High contrast mode
- [ ] Reduced motion support

---

## Phase 7: Testing ⏳

### Unit Tests
- [ ] HandConfiguration model tests
- [ ] ConditionalProbabilityEngine tests
  - [ ] Calculation accuracy
  - [ ] Edge cases
  - [ ] Performance benchmarks
- [ ] State management tests

### Integration Tests
- [ ] Navigation flow tests
- [ ] State persistence tests
- [ ] Voice input tests
- [ ] Performance under load

### UI Tests
- [ ] Screen flow tests
- [ ] Interaction tests
- [ ] Accessibility tests
- [ ] Device compatibility tests

### Manual Testing
- [ ] Test on all watch sizes
- [ ] Test with actual gameplay scenarios
- [ ] Battery impact testing
- [ ] Memory usage profiling

---

## Phase 8: Documentation ⏳

### Code Documentation
- [ ] Document ConditionalProbabilityEngine algorithm
- [ ] Document voice command patterns
- [ ] API documentation for new components
- [ ] Update CLAUDE.md with new features

### User Documentation
- [ ] Update app description for Screen 3
- [ ] Create help content for hand entry
- [ ] Document voice commands
- [ ] Update screenshots

---

## Completion Criteria ✅

- [ ] All tests passing
- [ ] Performance requirements met (<50ms)
- [ ] No modifications to existing ProbabilityEngine
- [ ] Full accessibility support
- [ ] Voice input working reliably
- [ ] Visual design matches PRD
- [ ] Edge cases handled gracefully
- [ ] Documentation complete

---

## Notes

- Update this checklist as items are completed
- Add any discovered tasks during implementation
- Mark items with ✅ when complete
- Use ⏳ for in-progress phases
- Use ❌ for blocked items