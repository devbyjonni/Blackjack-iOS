//
//  MockDeckManager.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-18.
//


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
        case .player6Cards:
            return [
                Card(suit: "Spades", rank: "Ace", value: 11),       // Player 1
                Card(suit: "Hearts", rank: "Nine", value: 9),       // Dealer 1
                Card(suit: "Clubs", rank: "Queen", value: 10),      // Player 2
                Card(suit: "Diamonds", rank: "Four", value: 4),     // Dealer 2
                
                Card(suit: "Hearts", rank: "Seven", value: 7),      // Player 3
                Card(suit: "Spades", rank: "Two", value: 2),        // Player 4
                Card(suit: "Diamonds", rank: "Six", value: 6),      // Player 5
                Card(suit: "Clubs", rank: "Five", value: 5)         // Player 6
            ]
            // Add more scenarios here as needed
        default:
            return []
        }
    }
}