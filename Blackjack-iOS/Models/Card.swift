import Foundation

/// The four suits in a standard deck.
enum Suit: String, CaseIterable, Codable {
    case spades = "Spades"
    case clubs = "Clubs"
    case hearts = "Hearts"
    case diamonds = "Diamonds"
}

/// The ranks in a standard deck and their base pip values.
enum Rank: String, CaseIterable, Codable {
    case ace = "Ace"
    case two = "Two"
    case three = "Three"
    case four = "Four"
    case five = "Five"
    case six = "Six"
    case seven = "Seven"
    case eight = "Eight"
    case nine = "Nine"
    case ten = "Ten"
    case jack = "Jack"
    case queen = "Queen"
    case king = "King"

    /// Base pip value for Blackjack (Ace as 1).
    var pipValue: Int {
        switch self {
        case .ace: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten, .jack, .queen, .king:
            return 10
        }
    }
}

/// Model for a playing card in Blackjack.
struct Card: Identifiable, Equatable, Codable, CustomStringConvertible {
    var id = UUID()
    let suit: Suit
    let rank: Rank

    /// The base value for scoring (Ace as 1).
    var pipValue: Int { rank.pipValue }

    /// Indicates if this card is an Ace.
    var isAce: Bool { rank == .ace }

    /// All possible blackjack values: Ace can be 1 or 11.
    var blackjackValues: [Int] {
        isAce ? [1, 11] : [pipValue]
    }

    /// A human-readable description (e.g., "Ace of Spades").
    var description: String {
        "\(rank.rawValue) of \(suit.rawValue)"
    }
}
