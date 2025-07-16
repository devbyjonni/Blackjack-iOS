import SwiftUI


struct Spotlight: View {
    var color: Color = .yellow
    var lineWidth: CGFloat = 6
    
    var body: some View {
        Circle()
            .strokeBorder(color, lineWidth: lineWidth)
            .frame(width: 280, height: 280)
            .opacity(0.9)
            .shadow(color: color.opacity(0.4), radius: 8)
            .allowsHitTesting(false)
    }
}
