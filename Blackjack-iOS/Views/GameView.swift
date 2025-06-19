import SwiftUI

struct GameView: View {
    @State private var gameViewManager = GameViewManager()
    @State private var animationSpeed: AnimationSpeed = .medium
    @State private var showDevMenu = false
    @State private var isGameOver = false
    @State private var isDealing = false
    @State private var currentIndex = 0
    
    // Decks
    @State private var currentDeck: [Card] = []
    @State private var playerCards: [Card] = []
    @State private var dealerCards: [Card] = []
    
    @State private var isPlayerTurn: Bool = false
    
    // Scores
    @State var dealerScore = 0
    @State var playerScore = 0
    
    var body: some View {
        ZStack {
            VStack {
                FanCardsView(gameViewManager: gameViewManager, cards: dealerCards, isDealerCard: true, isGameOver: false, dealerScore: dealerScore, playerScore: playerScore)
                    .opacity(isPlayerTurn ? 0.5 : 0.5)
                
                Text("Logo View Goes Here")
                
                FanCardsView(gameViewManager: gameViewManager, cards: playerCards, isDealerCard: false, isGameOver: false, dealerScore: dealerScore, playerScore: playerScore)
                    .opacity(isPlayerTurn ? 0.5 : 0.5)
                
                Spacer()
                if isPlayerTurn {
                    HStack {
                        GameButton(title: "STAND") {
                            // Dev
                        }
                        GameButton(title: "HIT") {
                            // Dev
                            addPlayerCard()
                        }
                    }
                } else {
                    GameButton(title: "Deal") {
                        // Dev
                        handleDevScenario(DevScenario.initialDeal)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Custom_Green"))
        }
        .overlay(alignment: .bottomTrailing) {
            DevMenu(isVisible: $showDevMenu, animationSpeed: $animationSpeed)
        }
        .onReceive(NotificationCenter.default.publisher(for: .devSelectedScenario)) { notification in
            if let scenario = notification.object as? DevScenario {
                resetGame()
                handleDevScenario(scenario)
            } else {
                print("⚠️ Unknown Dev Scenario received.")
            }
        }
    }
    
    private func resetGame() {
        currentDeck = []
        playerCards = []
        dealerCards = []
        dealerScore = 0
        playerScore = 0
        currentIndex = 0
        isDealing = false
        isPlayerTurn = false
    }
}

extension GameView {
    private func dealOpeningCards() {
        guard !isDealing else { return }
        isDealing = true
        
        print("🃏 Dealing initial cards...")
        
        let delayUnit = animationSpeed.delay
        
        func addCard(_ card: Card, after delay: TimeInterval) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation {
                    if currentIndex % 2 == 0 {
                        playerCards.append(card)
                        playerScore += card.value
                    } else {
                        dealerCards.append(card)
                        dealerScore += card.value
                    }
                }
                
                currentIndex += 1
                
                if currentIndex == currentDeck.count {
                    isDealing = false
                }
                
                if currentIndex >= 3 {
                    withAnimation {
                        isPlayerTurn = true
                    }
                }
            }
        }
        
        addCard(currentDeck[0], after: delayUnit * 1)
        addCard(currentDeck[1], after: delayUnit * 2)
        addCard(currentDeck[2], after: delayUnit * 3)
        addCard(currentDeck[3], after: delayUnit * 4)
    }
    
    private func addPlayerCard() {
        withAnimation {
            playerCards.append(currentDeck[currentIndex])
            playerScore += currentDeck[currentIndex].value
        }
        
        currentIndex += 1
    }
}

extension GameView {
    private func handleDevScenario(_ scenario: DevScenario) {
        guard !isDealing else { return }
        
        print("🧪 Dev Scenario Triggered: \(scenario.rawValue)")
        
        switch scenario {
        case .initialDeal:
            currentDeck = MockDeckManager.deck(for: scenario)
            dealOpeningCards()
        case .player6Cards:
            currentDeck = MockDeckManager.deck(for: scenario)
            dealOpeningCards()
        default:
            print("🧪 Scenario '\(scenario.label)' not wired yet.")
        }
    }
}
