//
//  DevMenu.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-17.
//

import SwiftUI

struct DevMenu: View {
    @Binding var isVisible: Bool
    @Binding var animationSpeed: AnimationSpeed
    @Binding var selectedScenario: DevScenario
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if isVisible {
                VStack(alignment: .leading, spacing: 12) {
                    DevMenuLabel(text: "DEV MENU")
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    SegmentedControlView(selection: $animationSpeed)
                        .frame(width: 180)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(DevScenario.allCases) { scenario in
                                DevMenuButton(
                                    title: scenario.label,
                                    isSelected: scenario == selectedScenario // pass this in!
                                ) {
                                    NotificationCenter.default.post(name: .devSelectedScenario, object: scenario)
                                    selectedScenario = scenario // update selection!
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 360) // Adjust as needed to limit height
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
                .shadow(radius: 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Button {
                withAnimation {
                    isVisible.toggle()
                }
            } label: {
                Text("DEV")
                    .font(.caption).bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .cornerRadius(10)
                    .shadow(radius: 4)
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 20)
        .frame(width: 280, alignment: .trailing)
    }
}

extension Notification.Name {
    static let devSelectedScenario = Notification.Name("devSelectedScenario")
}
