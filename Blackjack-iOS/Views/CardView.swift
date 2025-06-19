//
//  CardView.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-17.
//

import SwiftUI

struct CardView: View {
    let card: Card
    
    /// Determines whether the card should be displayed face-up (`true`) or face-down (`false`).
    let isFaceUp: Bool
    
    var body: some View {
        let rankMapping: [String: String] = [
            "A": "Ace", "2": "Two", "3": "Three", "4": "Four", "5": "Five",
            "6": "Six", "7": "Seven", "8": "Eight", "9": "Nine", "10": "Ten",
            "J": "Jack", "Q": "Queen", "K": "King"
        ]
        
        let rankName = rankMapping[card.rank] ?? card.rank
        let suitName = card.suit.trimmingCharacters(in: .whitespaces)
        let imageName = isFaceUp ? "\(rankName)_\(suitName)" : "Face_Down_Card"
        
        return Image(imageName)
            .resizable()
            .scaledToFit()
            .shadow(radius: 2, x: 2, y: 2)
    }
}
