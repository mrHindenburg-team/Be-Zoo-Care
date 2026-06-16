import StoreKit
import Observation

@Observable
@MainActor
final class SubscriptionManager {

    // MARK: - State

    var products: [Product] = []
    var purchaseStatus: PurchaseStatus = .initial
    var purchasedProductIDs: Set<String> = []

    // MARK: - Private

    @ObservationIgnored private var updatesTask: Task<Void, Never>?
    @ObservationIgnored private var intentsTask: Task<Void, Never>?

    // MARK: - Init / Deinit

    init() {
        updatesTask = observeTransactionUpdates()
        intentsTask = observePurchaseIntents()

        Task {
            await fetchProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
        intentsTask?.cancel()
    }

    // MARK: - Public API

    func isPurchased(_ id: SubscriptionID) -> Bool {
        purchasedProductIDs.contains(id.rawValue)
    }

    func fetchProducts() async {
        let ids = SubscriptionID.allCases.map(\.rawValue)
        do {
            let loaded = try await Product.products(for: ids)
            products = loaded.sorted { $0.price < $1.price }
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }

    func buyProduct(_ product: Product) async {
        purchaseStatus = .loading

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    purchaseStatus = .error("Transaction verification failed")
                    resetStatusAfterDelay()
                    return
                }
                purchasedProductIDs.insert(transaction.productID)
                purchaseStatus = .success("Purchase successful!")
                resetStatusAfterDelay()
                await transaction.finish()

            case .userCancelled:
                purchaseStatus = .initial

            case .pending:
                purchaseStatus = .loading

            @unknown default:
                break
            }
        } catch {
            purchaseStatus = .error(error.localizedDescription)
            resetStatusAfterDelay()
        }
    }

    func restorePurchases() async {
        purchaseStatus = .loading

        do {
            try await AppStore.sync()
            await refreshEntitlements()

            if purchasedProductIDs.isEmpty {
                purchaseStatus = .nothingToRestore
            } else {
                purchaseStatus = .restored
            }
        } catch {
            purchaseStatus = .error(error.localizedDescription)
        }

        resetStatusAfterDelay()
    }

    // MARK: - Entitlements

    func refreshEntitlements() async {
        var active: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                // Only include active subscriptions (not expired or revoked)
                if transaction.revocationDate == nil {
                    active.insert(transaction.productID)
                }
            }
        }

        purchasedProductIDs = active
    }

    // MARK: - Private Helpers

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(verificationResult: result)
            }
        }
    }

    private func observePurchaseIntents() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await intent in PurchaseIntent.intents {
                await self?.buyProduct(intent.product)
            }
        }
    }

    private func handle(verificationResult: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verificationResult else { return }

        if transaction.revocationDate != nil {
            purchasedProductIDs.remove(transaction.productID)
        } else {
            purchasedProductIDs.insert(transaction.productID)
        }

        await transaction.finish()
    }

    private func resetStatusAfterDelay() {
        Task {
            try? await Task.sleep(for: .seconds(3))
            purchaseStatus = .initial
        }
    }
}
