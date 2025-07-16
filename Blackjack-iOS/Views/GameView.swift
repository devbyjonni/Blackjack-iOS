import SwiftUI

struct GameView: View {
    @State var animationSpeed: AnimationSpeed = .medium
    @State var currentScenario: DevScenario = .noForce
    @State var showDevMenu = false
    @State var deck = Deck()
    @State var outcome: Outcome? = nil
    @State var gamePhase: GamePhase = .idle
    @State var dealerCards: [Card] = []
    @State var playerCards: [Card] = []
    @State var playerSplitCards: [Card] = []
    @State var canSplit = false
    @State var didSplit = false
    @State var showSplitPrompt = false
    @State var activeHand: Int = 0
    @State var leftHandBusted: Bool = false
    @State var rightHandBusted: Bool = false

    var leftHandScore: Int { calculateHandScore(playerCards) }
    var rightHandScore: Int { calculateHandScore(playerSplitCards) }
    var dealerScore: Int { calculateHandScore(dealerCards) }
    var playerScore: Int { calculateHandScore(playerCards) }

    var body: some View {
        ZStack {
            VStack {
                // Dealer hand with highlight if dealer turn
                FanCardsView(
                    cards: dealerCards,
                    isDealerCard: true,
                    isGameOver: gamePhase == .gameOver,
                    dealerScore: dealerScore,
                    playerScore: playerScore,
                    highlighted: gamePhase == .dealerTurn
                )
                
                Text("Logo View Goes Here")
                if didSplit {
                    HStack {
                        // Left (main) hand, highlight if player's turn and this hand is active
                        FanCardsView(
                            cards: playerCards,
                            isDealerCard: false,
                            isGameOver: gamePhase == .gameOver,
                            dealerScore: dealerScore,
                            playerScore: leftHandScore,
                            highlighted: gamePhase == .playerTurn && activeHand == 0
                        )
                        // Right (split) hand, highlight if player's turn and this hand is active
                        FanCardsView(
                            cards: playerSplitCards,
                            isDealerCard: false,
                            isGameOver: gamePhase == .gameOver,
                            dealerScore: dealerScore,
                            playerScore: rightHandScore,
                            highlighted: gamePhase == .playerTurn && activeHand == 1
                        )
                    }
                } else {
                    // Single player hand, highlight if player's turn
                    FanCardsView(
                        cards: playerCards,
                        isDealerCard: false,
                        isGameOver: gamePhase == .gameOver,
                        dealerScore: dealerScore,
                        playerScore: playerScore,
                        highlighted: gamePhase == .playerTurn
                    )
                }
                Spacer()
                // --------- ACTION BUTTONS ---------
                switch gamePhase {
                case .idle:
                    GameButton(title: "Deal") {
                        startNewGame()
                    }
                case .playerTurn:
                    if outcome == nil {
                        HStack(spacing: 20) {
                            if canSplit && !showSplitPrompt {
                                GameButton(title: "SPLIT") {
                                    handleSplitTapped()
                                }
                            }
                            GameButton(title: "STAND") { playerStands() }
                            GameButton(title: "HIT") { addPlayerCard() }
                        }
                    }
                default:
                    EmptyView()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Custom_Green"))
            .allowsHitTesting(!showSplitPrompt)
            .overlay(alignment: .center) {
                if let result = outcome {
                    OutcomeModal(outcome: result)
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showSplitPrompt {
                SplitPrompt(
                    onYes: {
                        withAnimation {
                            showSplitPrompt = false
                            handleSplitTapped()
                        }
                    },
                    onNo: {
                        withAnimation {
                            showSplitPrompt = false
                        }
                        canSplit = false
                    }
                )
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
                    deck = Deck()
                case .forceSplitScenario:
                    deck = Deck(mockCards: MockDeckManager.forceSplitScenario())
                case .forceSplitScenarioLeftHandBlackjack:
                    deck = Deck(mockCards: MockDeckManager.forceSplitScenarioleftHandBlackjack())
                case .forcePlayerBlackjack:
                    deck = Deck(mockCards: MockDeckManager.forcePlayerBlackjack())
                case .forceAceScenarios:
                    deck = Deck(mockCards: MockDeckManager.forceAceScenarios())
                }
                resetGame()
                currentScenario = scenario
            } else {
                print("⚠️ Unknown Dev Scenario received.")
            }
        }
    }
    
    // ---------- LOGIC BELOW ----------
    
    private func startNewGame() {
        resetGame()
        gamePhase = .dealing
        let delayUnit = animationSpeed.delay
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayUnit) {
            for index in 0...3 {
                let cardDelay = delayUnit * Double(index)
                DispatchQueue.main.asyncAfter(deadline: .now() + cardDelay) {
                    if let card = deck.dealOne() {
                        if index % 2 == 0 {
                            playerCards.append(card)
                            DispatchQueue.main.asyncAfter(deadline: .now() + cardDelay) {
                                // --- SPLIT CHECK: after both player cards are present ---
                                if playerCards.count == 2 {
                                    if playerCards[0].rank == playerCards[1].rank {
                                        withAnimation {
                                            showSplitPrompt = true
                                            canSplit = true
                                        }
                                    } else {
                                        canSplit = false
                                    }
                                    // --- BLACKJACK CHECK
                                    if isPlayerBlackjack(playerCards) {
                                        outcome = .playerBlackjack
                                        withAnimation { gamePhase = .gameOver }
                                        let resetDelay = animationSpeed.delay + 3.0
                                        DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) {
                                            outcome = nil
                                            resetGame()
                                        }
                                    }
                                }
                            }
                        } else {
                            dealerCards.append(card)
                            // No need to handle scores, will always use calculated
                        }
                    }
                    // Only enable player input after the last card dealt
                    if index == 3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + delayUnit) {
                            withAnimation {
                                gamePhase = .playerTurn
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addPlayerCard() {
        guard gamePhase == .playerTurn else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.delay) {
            if let card = deck.dealOne() {
                if didSplit {
                    if activeHand == 0 {
                        playerCards.append(card)
                        let cards = playerCards
                        let score = calculateHandScore(cards)
                        if cards.count == 2, isPlayerBlackjack(cards) {
                            outcome = .playerBlackjack
                            withAnimation { gamePhase = .gameOver }
                            DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.delay + 1.0) {
                                outcome = nil
                                withAnimation { gamePhase = .playerTurn }
                                activeHand = 1
                            }
                            return
                        }
                        if score > 21 {
                            leftHandBusted = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.delay) {
                                activeHand = 1
                            }
                        } else if score == 21 {
                            activeHand = 1
                        }
                    } else {
                        playerSplitCards.append(card)
                        let cards = playerSplitCards
                        let score = calculateHandScore(cards)
                        if cards.count == 2, isPlayerBlackjack(cards) {
                            outcome = .playerBlackjack
                            withAnimation { gamePhase = .gameOver }
                            DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.delay + 1.0) {
                                outcome = nil
                                // Both hands finished, go to dealer
                                withAnimation { gamePhase = .dealerTurn }
                                dealerDrawLoop()
                            }
                            return
                        }
                        if score > 21 {
                            rightHandBusted = true
                            if leftHandBusted {
                                outcome = .dealerWins
                                withAnimation { gamePhase = .gameOver }
                                let resetDelay = animationSpeed.delay + 3.0
                                DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) {
                                    outcome = nil
                                    resetGame()
                                }
                            } else {
                                withAnimation { gamePhase = .dealerTurn }
                                dealerDrawLoop()
                            }
                        } else if score == 21 {
                            withAnimation { gamePhase = .dealerTurn }
                            dealerDrawLoop()
                        }
                    }
                } else {
                    // Regular single-hand play
                    playerCards.append(card)
                    let score = calculateHandScore(playerCards)
                    if score > 21 {
                        checkForOutcome()
                    } else if score == 21 {
                        playerStands()
                    }
                }
            }
        }
    }

    // Keep your ace score function!
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
