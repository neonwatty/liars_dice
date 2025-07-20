# Screen 3 Implementation Checklist

## Overview
This checklist tracks the implementation of Screen 3 (Confirmed Hand Entry) for the Liar's Dice Probability Watch App. It will be updated as progress is made.

**Key Constraint**: No modifications to existing ProbabilityEngine.swift - all new calculations use separate ConditionalProbabilityEngine.swift

---

## Phase 1: Core Infrastructure ⏳

### Models and Data Structures
- [ ] Create `HandConfiguration.swift` model
  - [ ] Properties: diceCount, faceValues array, bidFace
  - [ ] Methods: countMatching(face:), isComplete(), reset()
  - [ ] Validation logic for face values (1-6 or nil)
  - [ ] Unit tests for model

### Probability Engine
- [ ] Create `ConditionalProbabilityEngine.swift`
  - [ ] Implement conditional probability calculation
  - [ ] Add caching for performance
  - [ ] Create comprehensive unit tests
  - [ ] Benchmark performance (<50ms requirement)
  - [ ] Document calculation method

### State Management
- [ ] Extend GameState with hand configuration
  - [ ] Add @Published handConfiguration property
  - [ ] Add methods to update hand configuration
  - [ ] Implement reset logic for upstream changes
  - [ ] Add navigation state for Screen 3

---

## Phase 2: Basic UI Implementation ⏳

### HandEntryView
- [ ] Create `HandEntryView.swift`
  - [ ] Implement basic layout with dice grid
  - [ ] Add bid face selector UI
  - [ ] Create die selection highlighting
  - [ ] Add navigation (back arrow)
  - [ ] Implement placeholder probability display

### Dice Display Components
- [ ] Create custom `DieView` component
  - [ ] Visual representation of die faces (1-6)
  - [ ] Empty state display
  - [ ] Selection state with border
  - [ ] Smooth animations
  - [ ] Accessibility labels

### Digital Crown Integration
- [ ] Implement Crown control for selected die
  - [ ] Value adjustment (1-6)
  - [ ] Haptic feedback
  - [ ] Focus management
  - [ ] Handle bid face selector mode

---

## Phase 3: Navigation and Integration ⏳

### Navigation Flow
- [ ] Add "Enter Hand" button to Screen 2
  - [ ] Show only when My Dice > 0
  - [ ] Appropriate icon/label
  - [ ] Accessibility support
  
- [ ] Implement navigation to Screen 3
  - [ ] Pass necessary state
  - [ ] Smooth transition animation
  - [ ] Preserve hand configuration during navigation

- [ ] Update navigation from Screen 3 to Screen 2
  - [ ] Maintain hand configuration
  - [ ] No modification to Screen 2 probability display

### State Synchronization
- [ ] Implement configuration reset logic
  - [ ] Clear on total dice change
  - [ ] Clear on my dice count change
  - [ ] Preserve during bid adjustments
  - [ ] Test state consistency

---

## Phase 4: Probability Display ⏳

### Visual Comparison
- [ ] Create probability comparison component
  - [ ] Original probability display
  - [ ] Conditional probability display
  - [ ] Difference indicator (arrow + percentage)
  - [ ] Color coding consistency

### Real-time Updates
- [ ] Connect UI to ConditionalProbabilityEngine
  - [ ] Update on each die value change
  - [ ] Update on bid face change
  - [ ] Performance optimization
  - [ ] Loading states if needed

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