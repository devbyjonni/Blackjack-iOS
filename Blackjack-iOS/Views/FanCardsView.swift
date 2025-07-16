import SwiftUI

struct FanCardsView: View {
    let cards: [Card]
    let isDealerCard: Bool
    let isGameOver: Bool
    let dealerScore: Int
    let playerScore: Int
    let dealerRevealed: Bool
    let isPlayerTurn = true
    let highlighted: Bool

    private let scoreHeaderHeight: CGFloat = 30
    private let cardHeight: CGFloat = 200
    private let cardAspect: CGFloat = 500.0 / 726.0
    private var cardWidth: CGFloat { cardHeight * cardAspect }
    private var overlapAmount: CGFloat { cardWidth * 0.4 }

    /// Score text for header (Dealer shows only upcard value if not revealed; both show "-" if empty)
    private var scoreDisplay: String {
        if cards.isEmpty {
            // No cards dealt yet
            return "-"
        }
        if isDealerCard {
            // Dealer: show real total only if revealed, otherwise just upcard pipValue
            if !dealerRevealed {
                return "\(cards.first!.pipValue)"
            }
            return "\(dealerScore)"
        } else {
            // Player hand: always show full score (after at least 1 card)
            return "\(playerScore)"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            scoreHeaderView
            GeometryReader { geo in
                let centerX = geo.size.width / 2
                let centerY = geo.size.height / 2
                ZStack {
                    if highlighted {
                        Spotlight(color: .yellow)
                            .position(x: centerX, y: centerY)
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
            }
            .frame(height: cardHeight)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: scoreHeaderHeight * 2 + cardHeight)
    }

    /// Score header view ("Dealer" or "Player" and score)
    private var scoreHeaderView: some View {
        VStack(spacing: 0) {
            Text(isDealerCard ? "Dealer" : "Player")
                .frame(height: scoreHeaderHeight)
            Text("Score: \(scoreDisplay)")
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

        let interCardSpacing: CGFloat = {
            switch totalCount {
            case 1: return 0
            case 2: return overlapAmount
            case 3...:
                return overlapAmount * (1 - CGFloat(totalCount - 2) * overlapTighteningFactor)
            default: return overlapAmount * maxOverlapFactor
            }
        }()

        // Dealer’s initial deal (first two cards side-by-side)
        if isDealerCard && index < 2 {
            let halfGap = overlapAmount * halfOverlapMultiplier
            let xPos = centerX + (index == 0 ? -halfGap : halfGap)
            return index == 0 ? xPos - overlapAmount : xPos + overlapAmount
        }

        // Standard fan layout
        switch totalCount {
        case 1:
            return centerX - overlapAmount * halfOverlapMultiplier
        case 2:
            return centerX + interCardSpacing * (index == 0 ? -halfOverlapMultiplier : halfOverlapMultiplier)
        default:
            let totalWidth = interCardSpacing * CGFloat(totalCount - 1)
            let startX = centerX - totalWidth / 2
            return startX + CGFloat(index) * interCardSpacing
        }
    }

    /// Determines if a card should be face-up; dealer’s second card remains face-down until revealed
    private func isCardFaceUp(at index: Int) -> Bool {
        !(isDealerCard && index == 1 && !dealerRevealed)
    }
}
