import SwiftUI


struct SplitPrompt: View {
    var onYes: () -> Void
    var onNo: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Do you want to split?")
                .font(.headline)
                .foregroundColor(.white)
            HStack(spacing: 30) {
                Button("Yes") {
                    onYes()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("No") {
                    onNo()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .frame(width: 600)
        .padding()
        .background(Color.black.opacity(0.9))
        .cornerRadius(14)
        .shadow(radius: 12)
        .transition(.scale)
    }
}
