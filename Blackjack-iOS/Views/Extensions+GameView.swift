import SwiftUI

// MARK: - Dealer Logic

extension GameView {
    /// Dealer draws cards until reaching 17 or higher, then checks for outcome.
    func dealerDrawLoop() {
        func drawNextCard(after delay: TimeInterval) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if dealerScore < 17, let card = deck.dealOne() {
                    dealerCards.append(card)
                    drawNextCard(after: animationSpeed.delay)
                } else {
                    checkForOutcome()
                }
            }
        }
        drawNextCard(after: animationSpeed.delay)
    }
    
    /// Determines if the dealer should peek at their face-down card for blackjack.
    func dealerShouldPeek() -> Bool {
        // Dealer peeks if upcard is Ace or 10/J/Q/K
        guard dealerCards.count >= 1 else { return false }
        let upcard = dealerCards[0]
        return upcard.rank == .ace || upcard.pipValue == 10
    }
    
    /// Returns true if dealer has blackjack with the first two cards.
    func isDealerBlackjack() -> Bool {
        guard dealerCards.count >= 2 else { return false }
        let ranks = [dealerCards[0].rank, dealerCards[1].rank]
        let tenRanks: [Rank] = [.ten, .jack, .queen, .king]
        return (ranks.contains(.ace) && ranks.contains(where: { tenRanks.contains($0) }))
    }
}

// MARK: - Blackjack Logic

extension GameView {
    /// Returns true if the given cards represent a blackjack (Ace + 10-value card).
    func isPlayerBlackjack(_ cards: [Card]) -> Bool {
        guard cards.count == 2 else { return false }
        let ranks = [cards[0].rank, cards[1].rank]
        let tenRanks: [Rank] = [.ten, .jack, .queen, .king]
        return (ranks.contains(.ace) && ranks.contains(where: { tenRanks.contains($0) }))
    }
    
    /// Calculates the best blackjack hand value, handling Aces as 1 or 11.
    func calculateHandScore(_ cards: [Card]) -> Int {
        var total = 0
        var aceCount = 0
        for card in cards {
            if card.rank == .ace {
                aceCount += 1
                total += 11
            } else {
                total += card.pipValue
            }
        }
        while total > 21 && aceCount > 0 {
            total -= 10
            aceCount -= 1
        }
        return total
    }
}

// MARK: - Outcome & Result Logic

extension GameView {
    /// Determines and sets the game outcome, then schedules game reset.
    func checkForOutcome() {
        let outcomeDelay = animationSpeed.delay + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + outcomeDelay) {
            if playerScore > 21 {
                outcome = .dealerWins
            } else if dealerScore > 21 {
                outcome = .playerWins
            } else if playerScore > dealerScore {
                outcome = .playerWins
            } else if dealerScore > playerScore {
                outcome = .dealerWins
            } else {
                outcome = .push
            }
            withAnimation {
                gamePhase = .gameOver
            }
            let resetDelay = animationSpeed.delay + 3.0
            DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) {
                outcome = nil
                resetGame()
            }
        }
    }
}

// MARK: - Split Logic

extension GameView {
    /// Handles player split action, dealing one card to each split hand.
    func handleSplitTapped() {
        guard playerCards.count == 2 else { return }
        // Move second card to split hand
        let splitCard = playerCards.removeLast()
        playerSplitCards = [splitCard]
        didSplit = true
        canSplit = false
        
        let delayUnit = animationSpeed.delay
        
        // Deal to left/main hand
        DispatchQueue.main.asyncAfter(deadline: .now() + delayUnit) {
            if let card = deck.dealOne() {
                playerCards.append(card)
            }
            // Deal to split hand (after another delay)
            DispatchQueue.main.asyncAfter(deadline: .now() + delayUnit) {
                if let card = deck.dealOne() {
                    playerSplitCards.append(card)
                }
                // Set active hand to first (left)
                activeHand = 0
            }
        }
    }
}

// MARK: - Player Actions

extension GameView {
    /// Handles the stand action for the current player hand.
    func playerStands() {
        guard gamePhase == .playerTurn else { return }
        if didSplit && activeHand == 0 {
            activeHand = 1 // Play right (split) hand next
            return
        }
        withAnimation {
            gamePhase = .dealerTurn
        }
        dealerDrawLoop()
    }
}

// MARK: - Game State/Reset

extension GameView {
    /// Resets all game state to start a new round.
    func resetGame() {
        dealerCards.removeAll()
        playerCards.removeAll()
        playerSplitCards.removeAll()
        canSplit = false
        didSplit = false
        showSplitPrompt = false
        outcome = nil
        leftHandBusted = false
        rightHandBusted = false
        activeHand = 0
        gamePhase = .idle
        deck.reset()
    }
}
