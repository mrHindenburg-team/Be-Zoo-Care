import SwiftUI

struct BZCPetCardView: View {
    let pet: BZCPet
    var isCompact: Bool = false

    @State private var isPulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if isCompact {
                compactCard
            } else {
                fullCard
            }
        }
    }

    private var fullCard: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
            cardHeader
            cardStats
        }
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                .fill(
                    LinearGradient(
                        colors: [pet.cardColor.opacity(0.70), pet.cardColor.opacity(0.40)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                        .strokeBorder(pet.cardColor.opacity(0.35), lineWidth: 1)
                )
        )
        .scaleEffect(isPulsing && !reduceMotion ? 1.015 : 1.0)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                .easeInOut(duration: BZCMotion.breatheDuration)
                .repeatForever(autoreverses: true)
            ) { isPulsing = true }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pet.name), \(pet.species.rawValue), wellness \(Int(pet.wellnessScore * 100))%")
    }

    private var compactCard: some View {
        HStack(spacing: BZCLayout.spacingDefault) {
            petAvatar(size: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(pet.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                Label(pet.species.rawValue, systemImage: "pawprint.fill")
                    .font(.caption)
                    .foregroundStyle(BZCColors.textSecondary)
            }

            Spacer()

            BZCWellnessRingView(score: pet.wellnessScore, size: 40, lineWidth: 5)
        }
        .padding(BZCLayout.paddingDefault)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                .fill(BZCColors.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadius)
                        .strokeBorder(BZCColors.glassBorder, lineWidth: 1)
                )
        )
    }

    private var cardHeader: some View {
        HStack(alignment: .top) {
            petAvatar(size: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(.title3.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Label(pet.species.rawValue, systemImage: "pawprint.fill")
                    .font(.subheadline)
                    .foregroundStyle(BZCColors.textSecondary)

                if !pet.breed.isEmpty {
                    Text(pet.breed)
                        .font(.caption)
                        .foregroundStyle(BZCColors.textTertiary)
                }
            }

            Spacer()

            BZCWellnessRingView(score: pet.wellnessScore, size: 56, lineWidth: 6)
        }
    }

    private var cardStats: some View {
        HStack(spacing: BZCLayout.spacingSmall) {
            statBadge(
                icon: "sun.max.fill",
                value: "\(pet.todaysCareCount)",
                label: "Today"
            )
            statBadge(
                icon: "calendar",
                value: pet.ageDescription,
                label: "Age"
            )
            statBadge(
                icon: "scalemass.fill",
                value: pet.weightKg > 0 ? String(format: "%.1f kg", pet.weightKg) : "–",
                label: "Weight"
            )
        }
    }

    private func statBadge(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Label(value, systemImage: icon)
                .font(.caption.bold())
                .foregroundStyle(BZCColors.textPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(BZCColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BZCLayout.paddingSmall)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusSmall))
    }

    private func petAvatar(size: CGFloat) -> some View {
        Group {
            if let data = pet.photoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(pet.cardColor.opacity(0.5))
                        .frame(width: size, height: size)
                    Image(systemName: pet.species.symbolName)
                        .font(.system(size: size * 0.42, weight: .semibold))
                        .foregroundStyle(pet.cardColor)
                }
            }
        }
    }
}
