//
//  GameViewManager.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-18.
//

import Foundation
import Observation

@Observable
class GameViewManager {
    var isSplit = false
    
    // Positions the center of this view at the specified coordinates in its parent’s coordinate space.
    // Card one
    var cardOneCenterX = CGFloat(0)
    var cardOneCenterY = CGFloat(0)
    // Card two
    var cardTwoCenterX = CGFloat(0)
    var cardTwoCenterY = CGFloat(0)
}
