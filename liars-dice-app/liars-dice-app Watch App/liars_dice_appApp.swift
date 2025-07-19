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
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DiceSelectionView()
            }
            .environmentObject(gameState)
        }
    }
}
