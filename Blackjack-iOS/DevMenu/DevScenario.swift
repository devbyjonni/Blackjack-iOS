enum DevScenario: String, CaseIterable, Identifiable {
    case noForce
    case forceSplitScenario
    case forceSplitScenarioLeftHandBlackjack
    case forcePlayerBlackjack
    case forceAceScenariosDealerBJ
    case forceAceScenariosBothBJ
    case forceAceScenariosNeitherBJ
    
    var id: String { rawValue }
}

extension DevScenario {
    var label: String {
        switch self {
        case .noForce:
            return "Normal Deck"
        case .forceSplitScenario:
            return "Force Split Scenario"
        case .forceSplitScenarioLeftHandBlackjack:
            return "Split & Left BJ"
        case .forcePlayerBlackjack:
            return "Force Player Blackjack"
        case .forceAceScenariosDealerBJ:
            return "Force Ace: Dealer Blackjack"
        case .forceAceScenariosBothBJ:
            return "Force Ace: Both Blackjack"
        case .forceAceScenariosNeitherBJ:
            return "Force Ace: Neither Blackjack"
        }
    }
}
