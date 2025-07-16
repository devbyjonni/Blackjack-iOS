//  CardView.swift
//  Blackjack-iOS
//
//  Updated by ChatGPT on 2025-07-14.

import SwiftUI

/// A SwiftUI view that displays a playing card, either face-up or face-down, with a flip animation.
struct CardView: View {
    // MARK: - Properties
    let card: Card
    let isFaceUp: Bool

    // MARK: - Body
    var body: some View {
        ZStack {
            // Show front or back based on `isFaceUp`
            if isFaceUp {
                Image("\(card.rank.rawValue)_\(card.suit.rawValue)")
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fit)
                    .shadow(radius: 2, x: 2, y: 2)
            } else {
                Image("Face_Down_Card")
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fit)
                    .shadow(radius: 2, x: 2, y: 2)
            }
        }
        // 3D flip effect
        .rotation3DEffect(
            .degrees(isFaceUp ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(
            .spring(response: 0.4, dampingFraction: 0.7),
            value: isFaceUp
        )
    }
}
