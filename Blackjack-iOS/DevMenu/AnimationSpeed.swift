//
//  AnimationSpeed.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-17.
//


import Foundation

enum AnimationSpeed: String, CaseIterable, Identifiable {
    case slow = "Slow"
    case medium = "Medium"
    case fast = "Fast"

    var id: String { rawValue }

    var delay: TimeInterval {
        switch self {
        case .slow: return 0.6
        case .medium: return 0.3
        case .fast: return 0.15
        }
    }
}