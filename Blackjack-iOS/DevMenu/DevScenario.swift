enum DevScenario: String, CaseIterable, Identifiable {
    case noForce
    case forceSplitScenario
    case forceSplitScenarioLeftHandBlackjack
    case forcePlayerBlackjack
    case forceAceScenarios
    
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
        case .forceAceScenarios:
            return "Force Ace Scenarios"
        }
    }
}
