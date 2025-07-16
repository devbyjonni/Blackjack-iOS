import SwiftUI

struct GameView: View {
    private enum Outcome {
        case playerWins, dealerWins, push, playerBlackjack
    }
    private enum GamePhase {
        case idle
        case dealing
        case playerTurn
        case dealerTurn
        case gameOver
    }
    
    @State private var deck = Deck()
    @State private var animationSpeed: AnimationSpeed = .medium
    @State private var currentScenario: DevScenario = .noForce
    @State private var showDevMenu = false
    @State private var outcome: Outcome? = nil
    
    @State private var gamePhase: GamePhase = .idle
    @State private var dealerScore = 0
    @State private var playerScore = 0
    
    @State private var dealerCards: [Card] = []
    @State private var playerCards: [Card] = []
    @State private var playerSplitCards: [Card] = []
    
    @State private var canSplit = false
    @State private var didSplit = false
    @State private var showSplitPrompt = false
    @State private var activeHand: Int = 0
    
    @State private var leftHandBusted: Bool = false
    @State private var rightHandBusted: Bool = false
    
    var leftHandScore: Int { playerCards.reduce(0) { $0 + $1.pipValue } }
    var rightHandScore: Int { playerSplitCards.reduce(0) { $0 + $1.pipValue } }
    
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
                            playerScore: leftHandScore, // ← Use computed left score!
                            highlighted: gamePhase == .playerTurn && activeHand == 0
                        )
                        // Right (split) hand, highlight if player's turn and this hand is active
                        FanCardsView(
                            cards: playerSplitCards,
                            isDealerCard: false,
                            isGameOver: gamePhase == .gameOver,
                            dealerScore: dealerScore,
                            playerScore: rightHandScore, // ← Use computed right score!
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
            
            // --------- OUTCOME MODAL ---------
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
        // --------- SPLIT PROMPT MODAL ---------
        .overlay(alignment: .bottom) {
            if showSplitPrompt {
                VStack(spacing: 20) {
                    Text("Do you want to split?")
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack(spacing: 30) {
                        Button("Yes") {
                            withAnimation {
                                showSplitPrompt = false
                                handleSplitTapped()
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        Button("No") {
                            withAnimation {
                                showSplitPrompt = false
                            }
                            canSplit = false
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .frame(width: 600)
                .padding()
                .background(Color.black.opacity(0.9))
                .cornerRadius(14)
                .shadow(radius: 12)
                .transition(.scale)
            }
        }
        .animation(.default, value: canSplit)
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
        let faceDownCardIndex = 3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayUnit) {
            for index in 0...3 {
                let cardDelay = delayUnit * Double(index)
                DispatchQueue.main.asyncAfter(deadline: .now() + cardDelay) {
                    if let card = deck.dealOne() {
                        if index % 2 == 0 {
                            playerCards.append(card)
                            DispatchQueue.main.asyncAfter(deadline: .now() + cardDelay) {
                                playerScore += card.pipValue
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
                            withAnimation {
                                gamePhase = .playerTurn
                            }
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
    
    private func resetGame() {
        dealerCards.removeAll()
        playerCards.removeAll()
        playerSplitCards.removeAll()
        dealerScore = 0
        playerScore = 0
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
    
    private func playerStands() {
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
        guard gamePhase == .playerTurn else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed.delay) {
            if let card = deck.dealOne() {
                if didSplit {
                    if activeHand == 0 {
                        playerCards.append(card)
                        let cards = playerCards
                        let score = cards.reduce(0) { $0 + $1.pipValue }
                        if cards.count == 2, isPlayerBlackjack(cards) {
                            // Show split-hand blackjack outcome
                            outcome = .playerBlackjack
                            withAnimation { gamePhase = .gameOver }
                            // Move to next hand after delay
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
                        let score = cards.reduce(0) { $0 + $1.pipValue }
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
                    playerScore += card.pipValue
                    if playerScore > 21 {
                        checkForOutcome()
                    } else if playerScore == 21 {
                        playerStands()
                    }
                }
            }
        }
    }
    
    
    private func dealerDrawLoop() {
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
