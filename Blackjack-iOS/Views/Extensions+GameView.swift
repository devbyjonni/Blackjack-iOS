//
//  Extensions+GameView.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-07-16.
//

import SwiftUI

// MARK: - Dealer Draw Logic

extension GameView {
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
}

// MARK: - Outcome & Result Logic

extension GameView {
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

// MARK: - Blackjack Logic

extension GameView {
    func isPlayerBlackjack(_ cards: [Card]) -> Bool {
        guard cards.count == 2 else { return false }
        let ranks = [cards[0].rank, cards[1].rank]
        let tenRanks: [Rank] = [.ten, .jack, .queen, .king]
        return (ranks.contains(.ace) && ranks.contains(where: { tenRanks.contains($0) }))
    }
}

// MARK: - Split Logic

extension GameView {
    func handleSplitTapped() {
        guard playerCards.count == 2 else { return }
        // 1. Move second card to split hand
        let splitCard = playerCards.removeLast()
        playerSplitCards = [splitCard]
        didSplit = true
        canSplit = false

        // 2. Immediately deal one card to each hand (with animation)
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
                // 3. Set to start with first hand (activeHand = 0)
                activeHand = 0
            }
        }
    }
}

// MARK: - Game State/Reset

extension GameView {
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

// MARK: - Player Action Logic

extension GameView {
    func playerStands() {
        guard gamePhase == .playerTurn else { return }
        if didSplit && activeHand == 0 {
            activeHand = 1 // Now play the split hand
            return
        }
        withAnimation {
            gamePhase = .dealerTurn
        }
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
}
