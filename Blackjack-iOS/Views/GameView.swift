//
//  GameView.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-17.
//

import SwiftUI

struct GameView: View {
    @State private var showDevMenu = false
    @State private var animationSpeed: AnimationSpeed = .medium
    @State private var cards: [Card] = []
    @State private var isGameOver = false
    @State private var currentIndex = 0
    @State private var isDealing = false

    private let cardWidth: CGFloat = 100

    @State private var currentDeck: [Card] = []

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("Logo View Goes Here")
                    .frame(height: 50)
                Spacer()

                // Dealer and Player Cards view goes here.

                Spacer()
                GameButton(title: "Deal") {
                    // Deal
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Custom_Green"))
        }
        .overlay(alignment: .bottomTrailing) {
            DevMenu(isVisible: $showDevMenu, animationSpeed: $animationSpeed)
        }
        .onReceive(NotificationCenter.default.publisher(for: .devSelectedScenario)) { notification in
            if let scenario = notification.object as? DevScenario {
                handleDevScenario(scenario)
            } else {
                print("⚠️ Unknown Dev Scenario received.")
            }
        }
    }
}


extension GameView {
    func handleDevScenario(_ scenario: DevScenario) {
        print("🧪 Dev Scenario Triggered: \(scenario.rawValue)")
        
        switch scenario {
        case .initialDeal:
            let deck = MockDeckManager.deck(for: scenario)
            currentDeck = deck
            print("👉 Initial Deal Deck:", deck)
            
        case .endPlayerWins:
            print("🏁 Would show: Player Wins")
            
        case .endDealerWins:
            print("🏁 Would show: Dealer Wins")
            
        case .endPush:
            print("🏁 Would show: Push (tie)")
            
        case .endSplitWin:
            print("🏁 Would show: Split Win")
            
        default:
            print("🧪 Scenario '\(scenario.label)' not wired yet.")
        }
    }
}

struct MockDeckManager {
    static func deck(for scenario: DevScenario) -> [Card] {
        switch scenario {
        case .initialDeal:
            return [
                Card(suit: "Spades", rank: "Ace", value: 11),     // Player 1
                Card(suit: "Hearts", rank: "King", value: 10),    // Dealer 1
                Card(suit: "Clubs", rank: "Six", value: 6),       // Player 2
                Card(suit: "Diamonds", rank: "Three", value: 3)   // Dealer 2
            ]
        case .playerBlackjack:
            return [
                Card(suit: "Spades", rank: "Ace", value: 11),     // Player 1
                Card(suit: "Hearts", rank: "Nine", value: 9),     // Dealer 1
                Card(suit: "Clubs", rank: "Queen", value: 10),    // Player 2
                Card(suit: "Diamonds", rank: "Four", value: 4)    // Dealer 2
            ]
        // Add more scenarios here as needed
        default:
            return []
        }
    }
}
