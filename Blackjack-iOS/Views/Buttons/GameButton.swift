//
//  GameButton.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-17.
//


import SwiftUI

struct GameButton: View {
    var title: String
    var action: () -> Void
    var width: CGFloat = 200
    var height: CGFloat = 70
    var font: Font = .title2
    var cornerRadius: CGFloat = 10
    var backgroundColor: Color = .black
    var foregroundColor: Color = .white

    var body: some View {
        Button(action: {
            withAnimation {
                action()
            }
        }) {
            Text(title.uppercased())
                .font(font)
                .bold()
                .foregroundColor(foregroundColor)
                .frame(width: width, height: height)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
                .shadow(radius: 4)
        }
    }
}