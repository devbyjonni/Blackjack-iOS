//
//  DevMenu.swift
//  Blackjack-iOS
//
//  Created by Jonni Akesson on 2025-06-17.
//

import SwiftUI
import Foundation

struct DevMenu: View {
    @Binding var isVisible: Bool
    @Binding var animationSpeed: AnimationSpeed

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
                                DevMenuButton(title: scenario.label) {
                                    NotificationCenter.default.post(name: .devSelectedScenario, object: scenario)
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
        .frame(width: 220, alignment: .trailing)
    }
}

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

struct DevMenuLabel: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.caption2)
            .bold()
            .foregroundColor(.white)
    }
}

enum DevScenario: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    // 🌟 Main Game States
    case initialDeal
    case playerBlackjack
    case dealerBlackjack
    case pushBlackjack
    case playerBust
    case dealerBust
    case dealerWins
    case pushEqual

    // 🔀 Split Flow
    case splitAvailable
    case splitChosen
    case splitHand1Playing
    case splitHand1Stand
    case splitHand2Playing
    case splitHand2Stand
    case splitDealerTurn
    case splitEndGame

    // 🏁 End States
    case endPlayerWins
    case endDealerWins
    case endPush
    case endSplitWin

    // 🎞 Visual & Animation Tests
    case testCardFlip
    case testFanSlideIn
    case testSpotlight
    case testSplitExpansion

    // 🧪 Debug & Control
    case resetUI
    case toggleCardFace
    case manualDealerDraw
    case showDebugInfo
    case toggleAnimationSpeed
}

extension DevScenario {
    var label: String {
        switch self {
        case .initialDeal: return "Initial Deal"
        case .playerBlackjack: return "Player Blackjack"
        case .dealerBlackjack: return "Dealer Blackjack"
        case .pushBlackjack: return "Push (21 vs 21)"
        case .playerBust: return "Player Bust"
        case .dealerBust: return "Dealer Bust"
        case .dealerWins: return "Dealer Wins"
        case .pushEqual: return "Push (Equal Score)"
        case .splitAvailable: return "Split Available"
        case .splitChosen: return "Split Chosen"
        case .splitHand1Playing: return "Split Hand 1 – Playing"
        case .splitHand1Stand: return "Split Hand 1 – Stand"
        case .splitHand2Playing: return "Split Hand 2 – Playing"
        case .splitHand2Stand: return "Split Hand 2 – Stand"
        case .splitDealerTurn: return "Split – Dealer Turn"
        case .splitEndGame: return "Split – End Game"
        case .endPlayerWins: return "End – Player Wins"
        case .endDealerWins: return "End – Dealer Wins"
        case .endPush: return "End – Push"
        case .endSplitWin: return "End – Split Win"
        case .testCardFlip: return "Test – Card Flip"
        case .testFanSlideIn: return "Test – Fan Slide"
        case .testSpotlight: return "Test – Spotlight"
        case .testSplitExpansion: return "Test – Split Expand"
        case .resetUI: return "Reset UI"
        case .toggleCardFace: return "Toggle Face/Back"
        case .manualDealerDraw: return "Manual Dealer Draw"
        case .showDebugInfo: return "Show GamePhase + Scores"
        case .toggleAnimationSpeed: return "Toggle Anim Speed"
        }
    }
}

extension Notification.Name {
    static let devSelectedScenario = Notification.Name("devSelectedScenario")
}
