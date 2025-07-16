import SwiftUI


struct FanCardsView: View {
    let cards: [Card]
    let isDealerCard: Bool
    let isGameOver: Bool
    let dealerScore: Int
    let playerScore: Int
    let isPlayerTurn = true
    let highlighted: Bool
    
    private let scoreHeaderHeight: CGFloat = 30
    private let cardHeight: CGFloat = 200
    private let cardAspect: CGFloat = 500.0 / 726.0
    private var cardWidth: CGFloat { cardHeight * cardAspect }
    private var overlapAmount: CGFloat { cardWidth * 0.4 }
    
    var body: some View {
        VStack(spacing: 0) {
            scoreHeaderView
            GeometryReader { geo in
                let centerX = geo.size.width / 2
                let centerY = geo.size.height / 2
                
                ZStack {
                    // 🔆 Only shows the glow if highlighted is true
                    if highlighted {
                        Spotlight(color: .yellow)
                            .position(x: centerX, y: centerY)
                           // .zIndex(-1)
                    }
                    ForEach(cards.indices, id: \.self) { index in
                        CardView(card: cards[index], isFaceUp: isCardFaceUp(at: index))
                            .frame(height: cardHeight)
                            .position(
                                x: isGameOver
                                ? centerX
                                : cardXPosition(at: index,
                                                centerX: centerX,
                                                overlapAmount: overlapAmount),
                                y: centerY
                            )
                            .zIndex(Double(index))
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .animation(.default, value: cards.count)
                // .border(.blue, width: 2) // Debug: show GeometryReader area
            }
            .frame(height: cardHeight)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: scoreHeaderHeight * 2 + cardHeight)
        //.border(.yellow, width: 3) // outer container debug
    }
    
    private var scoreHeaderView: some View {
        VStack(spacing: 0) {
            Text(isDealerCard ? "Dealer" : "Player")
                .frame(height: scoreHeaderHeight)
            Text("Score: \(isDealerCard ? dealerScore : playerScore)")
                .bold()
                .frame(height: scoreHeaderHeight)
        }
    }
    
    /// Calculates the horizontal x-position for each card based on its index
    private func cardXPosition(
        at index: Int,
        centerX: CGFloat,
        overlapAmount: CGFloat
    ) -> CGFloat {
        let totalCount = cards.count
        let overlapTighteningFactor: CGFloat = 0.05
        let maxOverlapFactor: CGFloat = 0.8
        let halfOverlapMultiplier: CGFloat = 0.5
        
        // Determine base spacing between card centers:
        // - 1 card: centered (no spacing)
        // - 2 cards: standard overlap spacing
        // - 3+ cards: tighten spacing for each additional card
        let interCardSpacing: CGFloat = {
            switch totalCount {
            case 1:
                return 0
            case 2:
                return overlapAmount
            case 3...:
                return overlapAmount * (1 - CGFloat(totalCount - 2) * overlapTighteningFactor)
            default:
                return overlapAmount * maxOverlapFactor
            }
        }()
        
        // Dealer’s initial flat deal (first two cards side-by-side):
        // Anchor at half-fan points, then remove overlap so they sit side-by-side.
        if isDealerCard && index < 2 {
            let halfGap = overlapAmount * halfOverlapMultiplier
            let xPos = centerX + (index == 0 ? -halfGap : halfGap)
            return index == 0 ? xPos - overlapAmount : xPos + overlapAmount
        }
        
        // Standard fan layout for all other cases:
        switch totalCount {
        case 1:
            // Single card: shift left by half overlap so center aligns
            return centerX - overlapAmount * halfOverlapMultiplier
            
        case 2:
            // Two-card fan (e.g., player’s first two cards)
            return centerX + interCardSpacing * (index == 0 ? -halfOverlapMultiplier : halfOverlapMultiplier)
            
        default: // totalCount >= 3
            // Center the fan by calculating the total width and offsetting
            let totalWidth = interCardSpacing * CGFloat(totalCount - 1)
            let startX = centerX - totalWidth / 2
            return startX + CGFloat(index) * interCardSpacing
        }
    }
    
    /// Determines if a card should be face-up; dealer’s second card remains face-down
    private func isCardFaceUp(at index: Int) -> Bool {
        !(isDealerCard && index == 1)
    }
}


