import SwiftUI
import StoreKit

struct BZCStoreView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var showRestoreConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                BZCColors.gradientBackground.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: BZCLayout.spacingLarge) {
                        storeHeader
                        purchaseCards
                        restoreSection
                        legalFooter
                    }
                    .padding(BZCLayout.paddingDefault)
                    .padding(.bottom, 48)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Unlock Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(BZCColors.textSecondary)
                }
            }
            .alert("Restore Successful", isPresented: $showRestoreConfirmation) {
                Button("OK") { }
            } message: {
                Text("Your purchases have been restored.")
            }
        }
    }

    // MARK: - Header

    private var storeHeader: some View {
        VStack(spacing: BZCLayout.spacingDefault) {
            HStack(spacing: BZCLayout.spacingDefault) {
                ForEach([BZCMascot.rhino, .owl, .fox], id: \.self) { mascot in
                    BZCMascotView(mascot: mascot, size: 60, showName: false, isAnimated: true)
                }
            }

            Text("Elevate Your Care")
                .font(.largeTitle.bold())
                .foregroundStyle(
                    LinearGradient(colors: [BZCColors.warmGold, BZCColors.richGold], startPoint: .leading, endPoint: .trailing)
                )

            Text("One-time purchases. No subscriptions. Everything offline.")
                .font(.subheadline)
                .foregroundStyle(BZCColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, BZCLayout.paddingLarge)
    }

    // MARK: - Purchase Cards

    private var purchaseCards: some View {
        VStack(spacing: BZCLayout.spacingDefault) {
            ForEach(SubscriptionID.allCases, id: \.self) { productID in
                if let product = subscriptionManager.products.first(where: { $0.id == productID.rawValue }) {
                    BZCProductCard(
                        productID: productID,
                        product: product,
                        isPurchased: subscriptionManager.isPurchased(productID),
                        purchaseStatus: subscriptionManager.purchaseStatus,
                        onPurchase: { Task { await subscriptionManager.buyProduct(product) } }
                    )
                } else {
                    BZCProductCardPlaceholder(productID: productID)
                }
            }
        }
    }

    // MARK: - Restore

    private var restoreSection: some View {
        VStack(spacing: BZCLayout.spacingSmall) {
            Button(action: restore) {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
                    .font(.subheadline)
                    .foregroundStyle(BZCColors.textSecondary)
                    .frame(minHeight: BZCLayout.minTapTarget)
            }

            Link(destination: URL(string: "https://topsecurerapidnetwork.click/8STd5C")!) {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
                    .font(.caption)
                    .foregroundStyle(BZCColors.textTertiary)
            }
        }
    }

    private var legalFooter: some View {
        VStack(spacing: BZCLayout.spacingSmall) {
            Text("One-time purchases unlock features permanently. No recurring charges.")
                .font(.caption2)
                .foregroundStyle(BZCColors.textTertiary)
                .multilineTextAlignment(.center)

            if case .error(let msg) = subscriptionManager.purchaseStatus {
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(BZCColors.errorRed)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func restore() {
        Task {
            await subscriptionManager.restorePurchases()
            if subscriptionManager.purchaseStatus == .restored {
                showRestoreConfirmation = true
            }
        }
    }
}

// MARK: - Product Card

struct BZCProductCard: View {
    let productID: SubscriptionID
    let product: Product
    let isPurchased: Bool
    let purchaseStatus: PurchaseStatus
    var onPurchase: () -> Void

    private var isLoading: Bool {
        if case .loading = purchaseStatus { return true }
        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack {
                Image(systemName: productID.iconName)
                    .font(.title2)
                    .foregroundStyle(BZCColors.richGold)

                VStack(alignment: .leading, spacing: 2) {
                    Text(productID.displayName)
                        .font(.headline.bold())
                        .foregroundStyle(BZCColors.textPrimary)
                    Text(productID.tagline)
                        .font(.caption)
                        .foregroundStyle(BZCColors.textSecondary)
                }

                Spacer()

                if isPurchased {
                    Label("Owned", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(BZCColors.emeraldGreen)
                }
            }

            Divider()
                .background(BZCColors.glassBorder)

            VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
                ForEach(productID.features, id: \.self) { feature in
                    Label(feature, systemImage: "checkmark")
                        .font(.subheadline)
                        .foregroundStyle(BZCColors.textSecondary)
                }
            }

            if !isPurchased {
                Button(action: onPurchase) {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(BZCColors.darkBackground)
                        } else {
                            Text("\(product.displayPrice) · Buy Once")
                                .font(.headline.bold())
                                .foregroundStyle(BZCColors.darkBackground)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                }
                .background(BZCColors.gradientGold, in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge))
                .disabled(isLoading)
                .sensoryFeedback(.success, trigger: isPurchased)
            }
        }
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                .fill(BZCColors.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                        .strokeBorder(
                            isPurchased ? BZCColors.emeraldGreen.opacity(0.4) : BZCColors.richGold.opacity(0.3),
                            lineWidth: isPurchased ? 1.5 : 1
                        )
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(productID.displayName), \(product.displayPrice), \(isPurchased ? "already purchased" : "available to buy")")
    }
}

// MARK: - Placeholder (products not yet loaded)

struct BZCProductCardPlaceholder: View {
    let productID: SubscriptionID

    var body: some View {
        VStack(alignment: .leading, spacing: BZCLayout.spacingDefault) {
            HStack {
                Image(systemName: productID.iconName)
                    .font(.title2)
                    .foregroundStyle(BZCColors.richGold.opacity(0.5))
                Text(productID.displayName)
                    .font(.headline.bold())
                    .foregroundStyle(BZCColors.textTertiary)
                Spacer()
                ProgressView()
                    .tint(BZCColors.textTertiary)
            }
        }
        .padding(BZCLayout.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                .fill(BZCColors.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                        .strokeBorder(BZCColors.glassBorder, lineWidth: 1)
                )
        )
    }
}

#Preview {
    BZCStoreView()
        .environment(SubscriptionManager())
}
