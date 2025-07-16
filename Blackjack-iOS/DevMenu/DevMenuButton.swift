import SwiftUI

struct DevMenuButton: View {
    let title: String
    var isSelected: Bool = false
    var color: Color = .blue
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? .green : color)
            .cornerRadius(8)
        }
        .contentShape(Rectangle())
    }
}
