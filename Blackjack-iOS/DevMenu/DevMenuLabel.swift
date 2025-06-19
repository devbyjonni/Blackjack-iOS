//
//  DevMenuLabel.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-18.
//

import SwiftUI

struct DevMenuLabel: View {
    let text: String
    
    var body: some View {
        Text(text.uppercased())
            .font(.caption2)
            .bold()
            .foregroundColor(.white)
    }
}
