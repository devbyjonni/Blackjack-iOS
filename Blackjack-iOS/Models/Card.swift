//
//  Card.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-17.
//


import Foundation

final class Card: Identifiable, ObservableObject {
    let id = UUID()
    let suit: String
    let rank: String
    let value: Int

    init(suit: String, rank: String, value: Int) {
        self.suit = suit
        self.rank = rank
        self.value = value
    }
}

extension Card: CustomStringConvertible {
    var description: String {
        "\(rank) of \(suit) (\(value))"
    }
}
