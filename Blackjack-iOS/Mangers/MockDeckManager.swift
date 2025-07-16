import Foundation

struct MockDeckManager {
    static func forceSplitScenario() -> [Card] {
        return [
            Card(suit: .spades, rank: .eight),   // Player 1: 8♠
            Card(suit: .hearts, rank: .king),    // Dealer 1: K♥
            Card(suit: .diamonds, rank: .eight), // Player 2: 8♦
            Card(suit: .clubs, rank: .five),     // Dealer 2: 5♣
        ]
    }
    
    static func forcePlayerBlackjack() -> [Card] {
        return [
            Card(suit: .spades, rank: .ace),      // Player 1: A♠
            Card(suit: .hearts, rank: .six),      // Dealer 1: 6♥
            Card(suit: .diamonds, rank: .king),   // Player 2: K♦
            Card(suit: .clubs, rank: .nine),      // Dealer 2: 9♣
        ]
    }
    
    static func forceSplitScenarioLeftHandBlackjack() -> [Card] {
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
    
    static func forceAceScenariosDealerBJ() -> [Card] {
        // Player: 9♣, 7♦   Dealer: A♠ (up), K♥ (down) → Dealer blackjack
        return [
            Card(suit: .clubs, rank: .nine),    // Player 1
            Card(suit: .spades, rank: .ace),    // Dealer 1 (face up)
            Card(suit: .diamonds, rank: .seven),// Player 2
            Card(suit: .hearts, rank: .king),   // Dealer 2 (face down)
        ]
    }

    static func forceAceScenariosBothBJ() -> [Card] {
        // Player: A♣, K♠   Dealer: A♠ (up), K♥ (down) → Both blackjack (push)
        return [
            Card(suit: .clubs, rank: .ace),     // Player 1
            Card(suit: .spades, rank: .ace),    // Dealer 1 (face up)
            Card(suit: .spades, rank: .king),   // Player 2
            Card(suit: .hearts, rank: .king),   // Dealer 2 (face down)
        ]
    }

    static func forceAceScenariosNeitherBJ() -> [Card] {
        // Player: 9♣, 7♦   Dealer: A♠ (up), 8♥ (down) → No one has blackjack
        return [
            Card(suit: .clubs, rank: .nine),    // Player 1
            Card(suit: .spades, rank: .ace),    // Dealer 1 (face up)
            Card(suit: .diamonds, rank: .seven),// Player 2
            Card(suit: .hearts, rank: .eight),  // Dealer 2 (face down)
        ]
    }
}
