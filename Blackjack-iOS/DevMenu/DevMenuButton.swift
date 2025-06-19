//
//  DevMenuButton.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-18.
//

import SwiftUI

struct DevMenuButton: View {
    let title: String
    var color: Color = .blue
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption2)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(color)
                .cornerRadius(8)
        }
        .contentShape(Rectangle())
    }
}
