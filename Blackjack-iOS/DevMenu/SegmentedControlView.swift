//
//  SegmentedControlView.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-17.
//


import SwiftUI

struct SegmentedControlView: View {
    @Binding var selection: AnimationSpeed
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(AnimationSpeed.allCases) { speed in
                Button(action: {
                    selection = speed
                }) {
                    Text(speed.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(selection == speed ? .white.opacity(0.1) : .clear)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.white.opacity(selection == speed ? 1 : 0), lineWidth: 1)
                        )
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selection)
    }
}