//
//  HandEntryView.swift
//  liars-dice-app Watch App
//
//  Screen 3: Enter hand configuration for conditional probability calculation
//

import SwiftUI

struct HandEntryView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDieIndex: Int = 0
    @State private var crownValue = 0.0
    @State private var crownMode: CrownMode = .myDiceCount
    @State private var hasInitializedDieSelection = false
    @State private var refreshID = UUID()
    
    private enum CrownMode {
        case myDiceCount
        case dieValue
        case bidFace
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                // Header
                headerView
                
                Spacer()
                
                // Main content area
                VStack(spacing: 12) {
                    if gameState.myDiceCount > 0 {
                        // Bid face selector
                        bidFaceSelectorView
                        
                        // Dice grid
                        diceGridView
                        
                        // Probability comparison
                        probabilityComparisonView
                    } else {
                        // Message when no dice
                        VStack(spacing: 8) {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("Set your dice count above")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 20)
                    }
                }
                
                Spacer()
                
                // Instructions
                instructionsView
            }
            .padding(.horizontal, 8)
            
            // Navigation back button
            backButtonView
        }
        .navigationBarHidden(true)
        .onAppear {
            setupInitialState()
        }
        .onChange(of: gameState.handConfiguration) { _, newValue in
            if newValue != nil && !hasInitializedDieSelection {
                // Only select first die on initial configuration setup
                selectFirstAvailableDie()
                hasInitializedDieSelection = true
            } else if newValue == nil {
                // Reset flag when configuration is cleared
                hasInitializedDieSelection = false
            }
        }
        .onChange(of: gameState.myDiceCount) { oldValue, newValue in
            print("HandEntry: myDiceCount changed from \(oldValue) to \(newValue)")
            // Update crown value to match
            if crownMode == .myDiceCount {
                crownValue = Double(newValue)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 4) {
            Text("My Dice")
                .font(.caption2)
                .foregroundColor(.gray)
            
            Button(action: {
                toggleCrownMode(.myDiceCount)
            }) {
                Text("\(gameState.myDiceCount)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(crownMode == .myDiceCount ? .blue : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(crownMode == .myDiceCount ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .focusable(crownMode == .myDiceCount)
            .digitalCrownRotation(
                $crownValue,
                from: 0,
                through: Double(gameState.totalDiceCount),
                by: 1,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownValue) { _, newValue in
                if crownMode == .myDiceCount {
                    let newCount = Int(newValue)
                    print("HandEntry: Updating myDiceCount to \(newCount)")
                    gameState.updateMyDiceCount(newCount)
                    
                    // Initialize hand configuration if we now have dice
                    if newCount > 0 && gameState.handConfiguration == nil {
                        print("HandEntry: Creating hand configuration after dice count update")
                        gameState.initializeHandConfiguration()
                    }
                }
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Bid Face Selector
    
    private var bidFaceSelectorView: some View {
        HStack {
            Text("Bid:")
                .font(.caption2)
                .foregroundColor(.gray)
            
            Button(action: {
                toggleCrownMode(.bidFace)
            }) {
                HStack(spacing: 4) {
                    DieView(
                        faceValue: gameState.handConfiguration?.bidFace,
                        size: 20,
                        isSelected: crownMode == .bidFace
                    )
                    
                    Text("\(gameState.handConfiguration?.bidFace ?? 1)s")
                        .font(.caption)
                        .foregroundColor(crownMode == .bidFace ? .blue : .white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(crownMode == .bidFace ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .focusable(crownMode == .bidFace)
            .digitalCrownRotation(
                $crownValue,
                from: 1,
                through: 6,
                by: 1,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownValue) { _, newValue in
                if crownMode == .bidFace {
                    gameState.updateHandBidFace(Int(newValue))
                }
            }
        }
    }
    
    // MARK: - Dice Grid
    
    private var diceGridView: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: min(gameState.myDiceCount, 3))
        
        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(0..<gameState.myDiceCount, id: \.self) { index in
                DieView(
                    faceValue: gameState.handConfiguration?.getDie(at: index),
                    size: dieSize,
                    isSelected: selectedDieIndex == index && crownMode == .dieValue
                )
                .id("\(index)-\(refreshID)")
                .onTapGesture {
                    selectDie(at: index)
                }
                .accessibilityLabel("Die \(index + 1)")
                .accessibilityValue(dieAccessibilityValue(at: index))
                .accessibilityHint("Tap to select, then rotate the Digital Crown to set value")
            }
        }
        .focusable(crownMode == .dieValue)
        .digitalCrownRotation(
            $crownValue,
            from: 1,
            through: 6,
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { oldValue, newValue in
            if crownMode == .dieValue {
                print("HandEntry: Crown onChange fired - old: \(oldValue), new: \(newValue), mode: \(crownMode)")
                let value = Int(newValue)
                print("HandEntry: Updating die \(selectedDieIndex) to value \(value)")
                gameState.updateHandDie(at: selectedDieIndex, to: value)
                // Force view refresh
                refreshID = UUID()
                
                // Verify the update
                if let updatedValue = gameState.handConfiguration?.getDie(at: selectedDieIndex) {
                    print("HandEntry: After crown update, die \(selectedDieIndex) value is: \(updatedValue)")
                } else {
                    print("HandEntry: ERROR - Die \(selectedDieIndex) is nil after crown update!")
                }
            }
        }
    }
    
    // MARK: - Probability Comparison
    
    private var probabilityComparisonView: some View {
        VStack(spacing: 4) {
            HStack {
                // Original probability
                VStack(spacing: 2) {
                    Text("Original")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.8))
                    
                    Text(gameState.probabilityPercentage)
                        .font(.caption)
                        .foregroundColor(gameState.probabilityColor)
                }
                
                Spacer()
                
                // Improvement indicator
                VStack(spacing: 2) {
                    Image(systemName: probabilityImprovementIcon)
                        .font(.caption2)
                        .foregroundColor(probabilityImprovementColor)
                    
                    Text(gameState.probabilityImprovementString)
                        .font(.caption2)
                        .foregroundColor(probabilityImprovementColor)
                }
                
                Spacer()
                
                // Conditional probability
                VStack(spacing: 2) {
                    Text("With Hand")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.8))
                    
                    Text(gameState.conditionalProbabilityPercentage)
                        .font(.caption)
                        .foregroundColor(gameState.conditionalProbabilityColor)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    // MARK: - Instructions
    
    private var instructionsView: some View {
        Text(instructionText)
            .font(.caption2)
            .foregroundColor(.gray.opacity(0.6))
            .padding(.bottom, 8)
    }
    
    private var instructionText: String {
        switch crownMode {
        case .myDiceCount: return "Crown: My Dice Count"
        case .bidFace: return "Crown: Bid Face"
        case .dieValue: return "Crown: Die Value"
        }
    }
    
    // MARK: - Back Button
    
    private var backButtonView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Back to probability view")
            .accessibilityHint("Return to the probability screen")
            
            Spacer()
        }
        .padding(.leading, 5)
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialState() {
        print("HandEntry: setupInitialState - myDiceCount: \(gameState.myDiceCount)")
        
        // Start with my dice count mode
        crownMode = .myDiceCount
        crownValue = Double(gameState.myDiceCount)
        
        // Initialize hand configuration if we have dice
        if gameState.myDiceCount > 0 && gameState.handConfiguration == nil {
            print("HandEntry: Initializing hand configuration")
            gameState.initializeHandConfiguration()
        } else if gameState.handConfiguration != nil {
            print("HandEntry: Hand configuration exists, selecting first die")
            // If configuration already exists, select first die immediately
            selectFirstAvailableDie()
        } else {
            print("HandEntry: No dice count set, cannot initialize hand configuration")
        }
        
        // If configuration doesn't exist yet, die selection will happen in onChange
    }
    
    private func selectDie(at index: Int) {
        print("HandEntry: selectDie called for index \(index)")
        selectedDieIndex = index
        toggleCrownMode(.dieValue)
        
        // Update crown value to current die value
        if let value = gameState.handConfiguration?.getDie(at: index) {
            crownValue = Double(value)
            print("HandEntry: Die \(index) has existing value: \(value)")
        } else {
            // Start at 1 for unset dice so user sees a face immediately
            crownValue = 1.0
            print("HandEntry: Die \(index) is unset, setting to 1")
            // Set the die to 1 immediately
            gameState.updateHandDie(at: index, to: 1)
            refreshID = UUID()
            
            // Verify the update
            if let newValue = gameState.handConfiguration?.getDie(at: index) {
                print("HandEntry: After update, die \(index) value is: \(newValue)")
            } else {
                print("HandEntry: ERROR - Die \(index) is still nil after update!")
            }
        }
    }
    
    private func selectFirstAvailableDie() {
        guard let config = gameState.handConfiguration else { return }
        
        // Find first unset die
        for i in 0..<config.diceCount {
            if config.getDie(at: i) == nil {
                selectedDieIndex = i
                // Start at 1 for unset dice so user sees a face immediately
                crownValue = 1.0
                // Set the die to 1 immediately
                gameState.updateHandDie(at: i, to: 1)
                refreshID = UUID()
                return
            }
        }
        
        // All dice are set, select the first one
        selectedDieIndex = 0
        if let value = config.getDie(at: 0) {
            crownValue = Double(value)
        }
    }
    
    private func toggleCrownMode(_ mode: CrownMode) {
        crownMode = mode
        
        switch mode {
        case .myDiceCount:
            crownValue = Double(gameState.myDiceCount)
        case .bidFace:
            crownValue = Double(gameState.handConfiguration?.bidFace ?? 1)
        case .dieValue:
            if let value = gameState.handConfiguration?.getDie(at: selectedDieIndex) {
                crownValue = Double(value)
            } else {
                // Start at 1 for unset dice so user sees a face immediately
                crownValue = 1.0
                // Set the die to 1 immediately
                gameState.updateHandDie(at: selectedDieIndex, to: 1)
                refreshID = UUID()
            }
        }
    }
    
    private func dieAccessibilityValue(at index: Int) -> String {
        if let value = gameState.handConfiguration?.getDie(at: index) {
            return "Showing \(value)"
        } else {
            return "Not set"
        }
    }
    
    // MARK: - Computed Properties
    
    private var dieSize: CGFloat {
        switch gameState.myDiceCount {
        case 1...3: return 32
        case 4...6: return 28
        default: return 24
        }
    }
    
    private var probabilityImprovementIcon: String {
        let improvement = gameState.probabilityImprovement
        if improvement > 0.01 {
            return "arrow.up"
        } else if improvement < -0.01 {
            return "arrow.down"
        } else {
            return "minus"
        }
    }
    
    private var probabilityImprovementColor: Color {
        let improvement = gameState.probabilityImprovement
        if improvement > 0.01 {
            return .green
        } else if improvement < -0.01 {
            return .red
        } else {
            return .gray
        }
    }
}

// MARK: - DieView Component

struct DieView: View {
    let faceValue: Int?
    let size: CGFloat
    let isSelected: Bool
    
    init(faceValue: Int?, size: CGFloat = 32, isSelected: Bool = false) {
        self.faceValue = faceValue
        self.size = size
        self.isSelected = isSelected
    }
    
    var body: some View {
        ZStack {
            // Die background
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(backgroundColor)
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.2)
                        .strokeBorder(borderColor, lineWidth: isSelected ? 2 : 1)
                )
            
            // Die face or empty state
            if let value = faceValue {
                dieFaceView(for: value)
            } else {
                Image(systemName: "questionmark")
                    .font(.system(size: size * 0.4, weight: .medium))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue.opacity(0.3)
        } else if faceValue != nil {
            return .white.opacity(0.9)
        } else {
            return .gray.opacity(0.2)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return .blue
        } else if faceValue != nil {
            return .gray
        } else {
            return .gray.opacity(0.5)
        }
    }
    
    @ViewBuilder
    private func dieFaceView(for value: Int) -> some View {
        let dotSize = size * 0.15
        let spacing = size * 0.25
        
        switch value {
        case 1:
            Circle()
                .fill(Color.black)
                .frame(width: dotSize, height: dotSize)
        case 2:
            VStack(spacing: spacing) {
                HStack {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
            }
            .frame(width: size * 0.6, height: size * 0.6)
        case 3:
            VStack(spacing: spacing * 0.7) {
                HStack {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
            }
            .frame(width: size * 0.6, height: size * 0.6)
        case 4:
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
            }
        case 5:
            VStack(spacing: spacing * 0.8) {
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
                HStack {
                    Spacer()
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Spacer()
                }
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
            }
        case 6:
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
                HStack(spacing: spacing) {
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                    Circle().fill(Color.black).frame(width: dotSize, height: dotSize)
                }
            }
        default:
            Text("\(value)")
                .font(.system(size: size * 0.5, weight: .bold))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    HandEntryView()
        .environmentObject(GameState())
}