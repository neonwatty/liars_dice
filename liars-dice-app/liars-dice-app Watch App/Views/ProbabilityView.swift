//
//  ProbabilityView.swift
//  liars-dice-app Watch App
//
//  Screen 2: Display bid probability with color-coded feedback
//

import SwiftUI

struct ProbabilityView: View {
    @EnvironmentObject var gameState: GameState
    @State private var crownValue = 0.0
    @State private var crownMode: CrownMode = .bidCount
    @Environment(\.dismiss) private var dismiss
    
    private enum CrownMode {
        case bidCount
        case bidFace
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 5) {
                // Header with break-even
                Text("Break-even: \(gameState.breakEvenBid)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                Spacer()
                
                // Current bid display
                VStack(spacing: 12) {
                    Text("Bid")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.8))
                    
                    // Bid count
                    Button(action: {
                        toggleCrownMode(.bidCount)
                    }) {
                        Text("\(gameState.currentBid)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(crownMode == .bidCount ? .blue : .white)
                            .frame(minWidth: 60)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .focusable(crownMode == .bidCount)
                    .digitalCrownRotation(
                        $crownValue,
                        from: 0,
                        through: Double(gameState.totalDiceCount),
                        by: 1,
                        sensitivity: .medium,
                        isContinuous: false,
                        isHapticFeedbackEnabled: true
                    )
                    .onChange(of: crownValue) { newValue in
                        if crownMode == .bidCount {
                            gameState.updateCurrentBid(Int(newValue))
                        } else if crownMode == .bidFace {
                            gameState.updateCurrentBidFace(Int(newValue))
                        }
                    }
                    .accessibilityLabel("Current bid")
                    .accessibilityValue("\(gameState.currentBid) dice")
                    .accessibilityHint("Tap to select, then rotate the Digital Crown to adjust")
                    
                    // Bid face selector
                    Button(action: {
                        toggleCrownMode(.bidFace)
                    }) {
                        HStack(spacing: 4) {
                            DieView(
                                faceValue: gameState.currentBidFace,
                                size: 24,
                                isSelected: crownMode == .bidFace
                            )
                            
                            Text("\(gameState.currentBidFace)s")
                                .font(.caption)
                                .foregroundColor(crownMode == .bidFace ? .blue : .white)
                        }
                        .padding(.horizontal, 10)
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
                    .accessibilityLabel("Bid face")
                    .accessibilityValue("\(gameState.currentBidFace)s")
                    .accessibilityHint("Tap to select, then rotate the Digital Crown to change face")
                    
                    // Probability display with color coding
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(gameState.probabilityColor.opacity(0.3))
                            .frame(height: 45)
                        
                        Text(gameState.probabilityPercentage)
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .foregroundColor(gameState.probabilityColor)
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("Probability of success")
                    .accessibilityValue("\(gameState.probabilityPercentage), \(gameState.probabilityDescription)")
                    .accessibilityHint("This shows the likelihood that at least \(gameState.currentBid) dice show the claimed face")
                }
                
                Spacer()
                
                // Probability description
                Text(gameState.probabilityDescription)
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.bottom, 10)
            }
            
            // Navigation arrows
            HStack {
                // Left arrow for navigation back
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
                .accessibilityLabel("Back to dice selection")
                .accessibilityHint("Return to the dice count selection screen")
                .accessibilityAddTraits(.isButton)
                
                Spacer()
                
                // Right arrow for navigation to hand entry
                NavigationLink(destination: HandEntryView().environmentObject(gameState)) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Enter your dice hand")
                .accessibilityHint("Navigate to hand entry screen for more accurate probability")
                .accessibilityAddTraits(.isButton)
            }
            .padding(.horizontal, 5)
        }
        .navigationBarHidden(true)
        .onAppear {
            // Set initial crown value based on current mode
            if crownMode == .bidCount {
                crownValue = Double(gameState.currentBid)
            } else {
                crownValue = Double(gameState.currentBidFace)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func toggleCrownMode(_ mode: CrownMode) {
        crownMode = mode
        
        switch mode {
        case .bidCount:
            crownValue = Double(gameState.currentBid)
        case .bidFace:
            crownValue = Double(gameState.currentBidFace)
        }
    }
}