import SwiftUI


struct OutcomeModal: View {
    let outcome: Outcome
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .cornerRadius(12)
                .shadow(radius: 10)
            VStack(spacing: 12) {
                switch outcome {
                case .playerWins:
                    Text("Dealer Bust!")
                        .font(.title3)
                    Text("You Win!")
                        .font(.title)
                        .italic()
                        .foregroundColor(.yellow)
                case .dealerWins:
                    Text("Dealer Wins")
                        .font(.title3)
                    Text("Better luck next time")
                        .font(.title)
                        .italic()
                        .foregroundColor(.yellow)
                case .push:
                    Text("Push")
                        .font(.title3)
                    Text("It's a tie")
                        .font(.title)
                        .italic()
                        .foregroundColor(.yellow)
                case .playerBlackjack:
                    Text("Blackjack!")
                        .font(.title)
                        .foregroundColor(.yellow)
                    Text("You win with a natural 21.")
                        .font(.title3)
                        .italic()
                }
            }
            .foregroundColor(.white)
            .fontWeight(.heavy)
        }
        .frame(width: 400, height: 200)
        .transition(.scale)
    }
}
