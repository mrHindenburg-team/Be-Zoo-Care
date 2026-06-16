import SwiftUI

struct BZCGlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder let content: Content

    init(cornerRadius: CGFloat = BZCLayout.cornerRadius, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(BZCColors.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(BZCColors.glassBorder, lineWidth: 1)
                    )
            )
    }
}

#Preview {
    ZStack {
        BZCColors.gradientBackground.ignoresSafeArea()
        BZCGlassCard {
            Text("Preview Card")
                .foregroundStyle(BZCColors.textPrimary)
                .padding()
        }
        .padding()
    }
}
