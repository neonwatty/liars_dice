//
//  OnboardingView.swift
//  liars-dice-app Watch App
//
//  First-launch onboarding overlay explaining app usage
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @Binding var showOnboarding: Bool
    
    private let onboardingSteps = [
        OnboardingStep(
            title: "Welcome to\nLiar's Dice Helper",
            description: "Calculate probabilities for Liar's Dice gameplay",
            icon: "die.face.6",
            instruction: "Tap to continue"
        ),
        OnboardingStep(
            title: "Digital Crown",
            description: "Rotate the Digital Crown to adjust dice count and bid values",
            icon: "crown",
            instruction: "Try rotating now"
        ),
        OnboardingStep(
            title: "Navigation",
            description: "Tap arrow buttons to move between screens",
            icon: "arrow.left.arrow.right",
            instruction: "Tap arrows to navigate"
        ),
        OnboardingStep(
            title: "Probability Rules",
            description: "Based on standard dice (no wild ones). Each die has 1/6 chance per face.",
            icon: "percent",
            instruction: "Tap to start using the app"
        )
    ]
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            if currentStep < onboardingSteps.count {
                OnboardingStepView(
                    step: onboardingSteps[currentStep],
                    stepNumber: currentStep + 1,
                    totalSteps: onboardingSteps.count
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if currentStep < onboardingSteps.count - 1 {
                            currentStep += 1
                        } else {
                            // Mark onboarding as complete
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            showOnboarding = false
                        }
                    }
                }
                .accessibilityLabel("Onboarding step \(currentStep + 1) of \(onboardingSteps.count)")
                .accessibilityValue("\(onboardingSteps[currentStep].title). \(onboardingSteps[currentStep].description)")
                .accessibilityHint(onboardingSteps[currentStep].instruction)
                .accessibilityAddTraits(.isButton)
            }
        }
        .navigationBarHidden(true)
    }
}

struct OnboardingStepView: View {
    let step: OnboardingStep
    let stepNumber: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 15) {
            // Progress indicators
            HStack(spacing: 6) {
                ForEach(1...totalSteps, id: \.self) { index in
                    Circle()
                        .fill(index <= stepNumber ? Color.white : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.top, 8)
            
            Spacer()
            
            // Icon
            Image(systemName: step.icon)
                .font(.system(size: 40))
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            // Title
            Text(step.title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 15)
            
            // Description
            Text(step.description)
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Instruction
            Text(step.instruction)
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.bottom, 20)
        }
    }
}

struct OnboardingStep {
    let title: String
    let description: String
    let icon: String
    let instruction: String
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}