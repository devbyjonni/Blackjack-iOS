import SwiftUI

struct GameView: View {
    // Animation speed for card dealing and other UI elements (slow, medium, fast, etc.)
    @State var animationSpeed: AnimationSpeed = .medium

    // The current developer test scenario (for mock decks and forced states)
    @State var currentScenario: DevScenario = .noForce

    // Controls visibility of the developer menu for debugging/testing
    @State var showDevMenu = false

    // The active deck being used for the game (real or mock cards)
    @State var deck = Deck()

    // The outcome of the current game round (win/loss/push/blackjack, etc.)
    @State var outcome: Outcome? = nil

    // The current phase of the game (idle, dealing, playerTurn, dealerTurn, gameOver)
    @State var gamePhase: GamePhase = .idle

    // The dealer's current hand of cards
    @State var dealerCards: [Card] = []

    // The player's primary hand of cards
    @State var playerCards: [Card] = []

    // The player's split hand (if a split has occurred), otherwise empty
    @State var playerSplitCards: [Card] = []

    // True if the player can currently split their hand
    @State var canSplit = false

    // True if the player has performed a split in this round
    @State var didSplit = false

    // Controls visibility of the split prompt (the dialog asking to split)
    @State var showSplitPrompt = false

    // Tracks which hand is currently active for the player (0 = left, 1 = right)
    @State var activeHand: Int = 0

    // Flags for busted hands when playing after a split
    @State var leftHandBusted: Bool = false
    @State var rightHandBusted: Bool = false

    // Shows the "dealer is peeking" animation/indicator (e.g., when checking for blackjack)
    @State var isDealerPeeking = false
    
    /// The current score for the left (main) player hand.
    /// Calculated every time the playerCards array changes.
    /// Handles Aces as 1 or 11 automatically.
    var leftHandScore: Int { calculateHandScore(playerCards) }

    /// The current score for the right (split) player hand.
    /// Updated dynamically from the playerSplitCards array.
    var rightHandScore: Int { calculateHandScore(playerSplitCards) }

    /// The current score for the dealer’s visible hand.
    /// Always up-to-date based on dealerCards array.
    var dealerScore: Int { calculateHandScore(dealerCards) }

    /// The score for the main player hand (alias for leftHandScore).
    /// Provided for convenience or legacy code compatibility.
    var playerScore: Int { calculateHandScore(playerCards) }
    
    
    
    /// Returns the score to show for the dealer in the UI,
    /// depending on the game phase:
    /// - If it's the dealer's turn or the game is over, show the *real* dealer score.
    /// - Otherwise (before the dealer reveals), show only the upcard's pip value (e.g., "A" = 1, "K" = 10).
    /// - If no cards yet, show 0.
    var dealerScoreForDisplay: Int {
        if gamePhase == .dealerTurn || gamePhase == .gameOver {
            return dealerScore // Reveal the full dealer score.
        } else if dealerCards.count > 0 {
            return dealerCards[0].pipValue // Show only the value of the upcard.
        } else {
            return 0 // No cards yet.
        }
    }

    /// Returns the visible score for the dealer:
    /// - During the initial deal or when idle, show only the upcard's score.
    /// - After that, reveal the full dealer score.
    /// This is useful for syncing what the player should see as the dealer’s visible score.
    var dealerVisibleScore: Int {
        // Show only the first card's score while the second card is still face-down
        if gamePhase == .dealing || gamePhase == .idle {
            return dealerCards.first.map { calculateHandScore([$0]) } ?? 0
        }
        // Otherwise, show the real dealer score (all cards)
        return dealerScore
    }
    
    
    
    var body: some View {
        ZStack {
            VStack {
                if isDealerPeeking {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text("👁️")
                                .font(.title)
                        )
                        .padding(.bottom, 8)
                        .transition(.scale)
                }
                // Dealer hand (top, only once!)
                FanCardsView(
                    cards: dealerCards,
                    isDealerCard: true,
                    isGameOver: gamePhase == .gameOver,
                    dealerScore: dealerVisibleScore, // ← use your computed property for visibility!
                    playerScore: playerScore, // This is only needed if you display it for some reason
                    dealerRevealed: gamePhase == .dealerTurn || gamePhase == .gameOver,
                    highlighted: gamePhase == .dealerTurn
                )

                Text("Logo View Goes Here")

                if didSplit {
                    HStack {
                        // Left hand (main)
                        FanCardsView(
                            cards: playerCards,
                            isDealerCard: false,
                            isGameOver: gamePhase == .gameOver,
                            dealerScore: dealerScore, // Not used, but fine to pass
                            playerScore: leftHandScore,
                            dealerRevealed: true,
                            highlighted: gamePhase == .playerTurn && activeHand == 0
                        )
                        // Right hand (split)
                        FanCardsView(
                            cards: playerSplitCards,
                            isDealerCard: false,
                            isGameOver: gamePhase == .gameOver,
                            dealerScore: dealerScore,
                            playerScore: rightHandScore,
                            dealerRevealed: true,
                            highlighted: gamePhase == .playerTurn && activeHand == 1
                        )
                    }
                } else {
                    FanCardsView(
                        cards: playerCards,
                        isDealerCard: false,
                        isGameOver: gamePhase == .gameOver,
                        dealerScore: dealerScore,
                        playerScore: playerScore, // Not leftHandScore!
                        dealerRevealed: true,
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
                    deck = Deck(mockCards: MockDeckManager.forceSplitScenarioLeftHandBlackjack())
                case .forcePlayerBlackjack:
                    deck = Deck(mockCards: MockDeckManager.forcePlayerBlackjack())
                case .forceAceScenariosDealerBJ:
                    deck = Deck(mockCards: MockDeckManager.forceAceScenariosDealerBJ())
                case .forceAceScenariosBothBJ:
                    deck = Deck(mockCards: MockDeckManager.forceAceScenariosBothBJ())
                case .forceAceScenariosNeitherBJ:
                    deck = Deck(mockCards: MockDeckManager.forceAceScenariosNeitherBJ())
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
                    // After all four cards have been dealt:
                    if index == 3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + delayUnit) {
                            if dealerShouldPeek() {
                                handleDealerPeek()  // Shows 👁️ for 2s, THEN continues
                            } else {
                                withAnimation { gamePhase = .playerTurn }
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
    
    func handleDealerPeek() {
        isDealerPeeking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isDealerPeeking = false
            if isDealerBlackjack() {
                if isPlayerBlackjack(playerCards) {
                    outcome = .push
                } else {
                    outcome = .dealerWins
                }
                withAnimation { gamePhase = .gameOver }
                
                // 🟢 Add delayed reset here!
                let resetDelay = animationSpeed.delay + 3.0
                DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) {
                    outcome = nil
                    resetGame()
                }
            } else {
                withAnimation { gamePhase = .playerTurn }
            }
        }
    }
}
