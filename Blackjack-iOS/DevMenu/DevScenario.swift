//
//  DevScenario.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-18.
//

enum DevScenario: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    // each case preloads a deck for selected case
    // New
    case player6Cards
    
    // 🌟 Main Game States
    case initialDeal
    case playerBlackjack
    case dealerBlackjack
    case pushBlackjack
    case playerBust
    case dealerBust
    case dealerWins
    case pushEqual
    
    // 🔀 Split Flow
    case splitAvailable
    case splitChosen
    case splitHand1Playing
    case splitHand1Stand
    case splitHand2Playing
    case splitHand2Stand
    case splitDealerTurn
    case splitEndGame
    
    // 🏁 End States
    case endPlayerWins
    case endDealerWins
    case endPush
    case endSplitWin
    
    // 🎞 Visual & Animation Tests
    case testCardFlip
    case testFanSlideIn
    case testSpotlight
    case testSplitExpansion
    
    // 🧪 Debug & Control
    case resetUI
    case toggleCardFace
    case manualDealerDraw
    case showDebugInfo
    case toggleAnimationSpeed
}

extension DevScenario {
    var label: String {
        switch self {
        case .initialDeal: return "Initial Deal"
        case .playerBlackjack: return "Player Blackjack"
        case .dealerBlackjack: return "Dealer Blackjack"
        case .pushBlackjack: return "Push (21 vs 21)"
        case .playerBust: return "Player Bust"
        case .dealerBust: return "Dealer Bust"
        case .dealerWins: return "Dealer Wins"
        case .pushEqual: return "Push (Equal Score)"
        case .splitAvailable: return "Split Available"
        case .splitChosen: return "Split Chosen"
        case .splitHand1Playing: return "Split Hand 1 – Playing"
        case .splitHand1Stand: return "Split Hand 1 – Stand"
        case .splitHand2Playing: return "Split Hand 2 – Playing"
        case .splitHand2Stand: return "Split Hand 2 – Stand"
        case .splitDealerTurn: return "Split – Dealer Turn"
        case .splitEndGame: return "Split – End Game"
        case .endPlayerWins: return "End – Player Wins"
        case .endDealerWins: return "End – Dealer Wins"
        case .endPush: return "End – Push"
        case .endSplitWin: return "End – Split Win"
        case .testCardFlip: return "Test – Card Flip"
        case .testFanSlideIn: return "Test – Fan Slide"
        case .testSpotlight: return "Test – Spotlight"
        case .testSplitExpansion: return "Test – Split Expand"
        case .resetUI: return "Reset UI"
        case .toggleCardFace: return "Toggle Face/Back"
        case .manualDealerDraw: return "Manual Dealer Draw"
        case .showDebugInfo: return "Show GamePhase + Scores"
        case .toggleAnimationSpeed: return "Toggle Anim Speed"
        case .player6Cards: return "player6Cards"
        }
    }
}
