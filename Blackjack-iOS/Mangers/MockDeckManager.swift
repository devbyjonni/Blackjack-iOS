import Foundation


struct MockDeckManager {
    static func forceSplitScenario() -> [Card] {
        return [
            // 4 cards to deal: P1, D1, P2, D2
            Card(suit: .spades, rank: .eight),   // Player 1: 8♠
            Card(suit: .hearts, rank: .king),    // Dealer 1: K♥
            Card(suit: .diamonds, rank: .eight), // Player 2: 8♦
            Card(suit: .clubs, rank: .five),     // Dealer 2: 5♣
        ]
    }
    
    static func forcePlayerBlackjack() -> [Card] {
        return [
            Card(suit: .spades, rank: .ace),      // Player 1: A♠
            Card(suit: .hearts, rank: .six),      // Dealer 1: 6♥ (any card, not Ace/10)
            Card(suit: .diamonds, rank: .king),   // Player 2: K♦
            Card(suit: .clubs, rank: .nine),      // Dealer 2: 9♣ (any)
        ]
    }
    
    static func forceSplitScenarioleftHandBlackjack() -> [Card] {
        return [
            Card(suit: .spades, rank: .ace),      // Player 1: A♠
            Card(suit: .hearts, rank: .king),     // Dealer 1: K♥
            Card(suit: .diamonds, rank: .ace),    // Player 2: A♦
            Card(suit: .clubs, rank: .five),      // Dealer 2: 5♣
            Card(suit: .spades, rank: .king),     // Left hand: K♠ (Blackjack!)
            Card(suit: .diamonds, rank: .three),  // Right hand: 3♦
        ]
    }
    
    static func forceAceScenarios() -> [Card] {
        return [
            Card(suit: .spades, rank: .ace),      // Player 1: A♠
            Card(suit: .hearts, rank: .eight),    // Dealer 1: 8♥
            Card(suit: .clubs, rank: .eight),     // Player 2: 8♣
            Card(suit: .diamonds, rank: .five),   // Dealer 2: 5♦
            Card(suit: .spades, rank: .five),     // Player draws 5♠ (forces ace as 1)
        ]
    }
}
