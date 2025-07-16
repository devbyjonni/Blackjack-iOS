final class Deck {
    private(set) var cards: [Card]
    private let numberOfDecks: Int
    private let reshuffleThreshold: Int
    private var rng = SystemRandomNumberGenerator()
    private let isMock: Bool
    private let originalMockCards: [Card]?
    
    init(decks: Int = 6) {
        self.isMock = false
        self.numberOfDecks = decks
        self.reshuffleThreshold = (52 * decks) / 3
        self.cards = Deck.buildDeck(multiple: decks)
        self.originalMockCards = nil
        self.shuffle()
    }
    
    init(mockCards: [Card]) {
        self.numberOfDecks = 1
        self.reshuffleThreshold = 1
        self.cards = mockCards
        self.originalMockCards = mockCards
        self.isMock = true
    }
    
    /// Rebuilds & reshuffles the shoe.
    func reset() {
        if isMock, let mock = originalMockCards {
            self.cards = mock
            return
        }
        cards = Deck.buildDeck(multiple: numberOfDecks)
        shuffle()
    }
    
    /// Shuffles using a secure RNG.
    func shuffle() {
        cards.shuffle(using: &rng)
    }
    
    /// Deals from the top, reshuffling if you dip below threshold.
    func dealOne() -> Card? {
        if cards.count < reshuffleThreshold {
            reset()
        }
        return cards.isEmpty ? nil : cards.removeFirst()
    }
    
    /// Draws a random card from anywhere in the shoe.
    func drawRandomCard() -> Card? {
        guard !cards.isEmpty else { return nil }
        let idx = Int.random(in: 0..<cards.count, using: &rng)
        return cards.remove(at: idx)
    }
    
    // MARK: - Private
    
    /// Generates `decks` full 52-card sets.
    private static func buildDeck(multiple decks: Int) -> [Card] {
        var result: [Card] = []
        result.reserveCapacity(52 * decks)
        for _ in 0..<decks {
            for suit in Suit.allCases {
                for rank in Rank.allCases {
                    result.append(Card(suit: suit, rank: rank))
                }
            }
        }
        return result
    }
}
