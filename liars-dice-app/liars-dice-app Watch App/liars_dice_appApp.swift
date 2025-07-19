//
//  liars_dice_appApp.swift
//  liars-dice-app Watch App
//
//  Created by Jeremy Watt on 7/19/25.
//

import SwiftUI

@main
struct liars_dice_app_Watch_AppApp: App {
    @StateObject private var gameState = GameState()
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showOnboarding {
                    OnboardingView(showOnboarding: $showOnboarding)
                } else {
                    NavigationStack {
                        DiceSelectionView()
                    }
                    .environmentObject(gameState)
                }
            }
        }
    }
}
