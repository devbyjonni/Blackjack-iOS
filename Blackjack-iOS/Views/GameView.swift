import SwiftUI

struct GameView: View {
    private enum Outcome {
        case playerWins, dealerWins, push, playerBlackjack
    }
    
    @State private var deck = Deck()
    @State private var animationSpeed: AnimationSpeed = .medium
    @State private var currentScenario: DevScenario = .noForce
    @State private var showDevMenu = false
    @State private var outcome: Outcome? = nil
    
    @State private var isGameOver = false
    @State private var isPlayerTurn = false
    @State private var canSplit = false
    @State private var dealerScore = 0
    @State private var playerScore = 0
    
    @State private var dealerCards: [Card] = []
    @State private var playerCards: [Card] = []
    @State private var playerSplitCards: [Card] = []
    
    @State private var didSplit = false
    
    var body: some View {
        ZStack {
            VStack {
                FanCardsView(
                    cards: dealerCards,
                    isDealerCard: true,
                    isGameOver: isGameOver,
                    dealerScore: dealerScore,
                    playerScore: playerScore
                )
                
                Text("Logo View Goes Here")
                
                if didSplit {
                    HStack {
                        FanCardsView(
                            cards: playerCards,
                            isDealerCard: false,
                            isGameOver: isGameOver,
                            dealerScore: dealerScore,
                            playerScore: playerScore
                        )
                        
                        FanCardsView(
                            cards: playerSplitCards, // Correct: use split hand
                            isDealerCard: false,
                            isGameOver: isGameOver,
                            dealerScore: dealerScore,
                            playerScore: playerScore
                        )
                    }
                } else {
                    FanCardsView(
                        cards: playerCards,
                        isDealerCard: false,
                        isGameOver: isGameOver,
                        dealerScore: dealerScore,
                        playerScore: playerScore
                    )
                }
                
                Spacer()
                
                if !isGameOver {
                    HStack {
                        if playerCards.isEmpty && dealerCards.isEmpty {
                            // New game: show Deal
                            GameButton(title: "Deal") {
                                resetGame()
                                startNewGame()
                            }
                        } else if isPlayerTurn {
                            HStack(spacing: 20) {
                                // Show SPLIT button if allowed
                                if canSplit {
                                    GameButton(title: "SPLIT") {
                                        handleSplitTapped()
                                    }
                                }
                                GameButton(title: "STAND") { playerStands() }
                                GameButton(title: "HIT") { addPlayerCard() }
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Custom_Green"))
            .animation(.default, value: isPlayerTurn)
            .animation(.default, value: isGameOver)
            
            if let result = outcome {
                ZStack {
                    Color.black.opacity(0.8)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                    VStack(spacing: 12) {
                        switch result {
                        case .playerWins:
                            Text("Dealer Bust!")
                                .font(.title3)
                            Text("You Win!")
                                .font(.title)
                                .italic()
                                .foregroundColor(.yellow)
                        case .dealerWins:
                            Text("Dealer Wins")
                                .font(.title3)
                            Text("Better luck next time")
                                .font(.title)
                                .italic()
                                .foregroundColor(.yellow)
                        case .push:
                            Text("Push")
                                .font(.title3)
                            Text("It's a tie")
                                .font(.title)
                                .italic()
                                .foregroundColor(.yellow)
                        case .playerBlackjack:
                            Text("Blackjack!")
                                .font(.title)
                                .foregroundColor(.yellow)
                            Text("You win with a natural 21.")
                                .font(.title3)
                                .italic()
                        }
                    }
                    .foregroundColor(.white)
                    .fontWeight(.heavy)
                }
                .frame(width: 400, height: 200)
                .transition(.scale)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: outcome)
        .overlay(alignment: .bottomTrailing) {
            DevMenu(
                isVisible: $showDevMenu,
                animationSpeed: $animationSpeed,
                selectedScenario: $currentScenario
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .devSelectedScenario)) { notification in
            if let scenario = notification.object as? DevScenario {
                switch scenario {
                case .noForce:
                    deck = Deck() // Use real, shuffled deck
                case .forceSplitScenario:
                    deck = Deck(mockCards: MockDeckManager.forceSplitScenario())
                case .forcePlayerBlackjack:
                    deck = Deck(mockCards: MockDeckManager.forcePlayerBlackjack())
                }
                resetGame()
                currentScenario = scenario
            } else {
                print("⚠️ Unknown Dev Scenario received.")
            }
        }
    }
    
    // Main deal logic: always deal from deck
    private func startNewGame() {
        resetGame()
        
        let delayUnit = animationSpeed.delay
        let faceDownCardIndex = 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayUnit) {
            for index in 0...3 {
                let cardDelay = delayUnit * Double(index)
                DispatchQueue.main.asyncAfter(deadline: .now() + cardDelay) {
                    if let card = deck.dealOne() {
                        if index % 2 == 0 {
                            // Player gets card
                            playerCards.append(card)
                            DispatchQueue.main.asyncAfter(deadline: .now() + cardDelay) {
                                playerScore += card.pipValue
                                
                                // --- SPLIT CHECK: after both player cards are present ---
                                if playerCards.count == 2 {
                                    if playerCards[0].rank == playerCards[1].rank {
                                        canSplit = true
                                    } else {
                                        canSplit = false
                                    }
                                    // 👇 BLACKJACK CHECK
                                    if isPlayerBlackjack(playerCards) {
                                        outcome = .playerBlackjack
                                        isGameOver = true
                                        // Optionally flip up the dealer's second card here
                                        // Optionally: reset after delay
                                        let resetDelay = animationSpeed.delay + 3.0
                                        DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) {
                                            outcome = nil
                                            resetGame()
                                        }
                                    }
                                }
                            }
                        } else {
                            // Dealer gets card
                            dealerCards.append(card)
                            DispatchQueue.main.asyncAfter(deadline: .now() + cardDelay) {
                                if index < faceDownCardIndex {
                                    dealerScore += card.pipValue
                                }
                            }
                        }
                    }
                    // Only enable player input after the last card dealt
                    if index == 3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + delayUnit) {
                            isPlayerTurn = true
                        }
                    }
                }
            }
        }
    }
    
    private func isPlayerBlackjack(_ cards: [Card]) -> Bool {
        guard cards.count == 2 else { return false }
        let ranks = [cards[0].rank, cards[1].rank]
        let tenRanks: [Rank] = [.ten, .jack, .queen, .king]
        return (ranks.contains(.ace) && ranks.contains(where: { tenRanks.contains($0) }))
    }
    
    private func handleSplitTapped() {
        // For now, just print/log. Later, show alert or implement split.
        didSplit = true
        canSplit = false
    }
    
    private func resetGame() {
        dealerCards.removeAll()
        playerCards.removeAll()
        playerSplitCards.removeAll()
        dealerScore = 0
        playerScore = 0
        isGameOver = false
        isPlayerTurn = false
        canSplit = false
        didSplit = false
        deck.reset()
    }
    
    private func playerStands() {
        guard isPlayerTurn else { return }
        isPlayerTurn = false
        
        func drawNextCard(after delay: TimeInterval) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if dealerScore < 17, let card = deck.dealOne() {
                    dealerCards.append(card)
                    dealerScore += card.pipValue
                    drawNextCard(after: animationSpeed.delay)
                } else {
                    checkForOutcome()
                }
            }
        }
        drawNextCard(after: animationSpeed.delay)
    }
    
    private func addPlayerCard() {
        guard isPlayerTurn, !isGameOver else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.delay) {
            if let card = deck.dealOne() {
                playerCards.append(card)
                playerScore += card.pipValue
                if playerScore > 21 {
                    checkForOutcome()
                } else if playerScore == 21 {
                    playerStands()
                }
            }
        }
    }
    
    private func checkForOutcome() {
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
            isGameOver = true
            let resetDelay = animationSpeed.delay + 3.0
            DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) {
                outcome = nil
                resetGame()
            }
        }
    }
}
