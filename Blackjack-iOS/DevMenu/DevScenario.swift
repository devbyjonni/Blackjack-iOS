enum DevScenario: String, CaseIterable, Identifiable {
    case noForce
    case forceSplitScenario
    case forcePlayerBlackjack

    var id: String { rawValue }
}

extension DevScenario {
    var label: String {
        switch self {
        case .noForce:                 return "Normal Deck"
        case .forceSplitScenario:      return "Force Split Scenario"
        case .forcePlayerBlackjack:    return "Force Player Blackjack"
        }
    }
}
