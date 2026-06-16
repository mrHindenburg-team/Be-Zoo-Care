enum PurchaseStatus: Equatable {
    case initial
    case loading
    case success(String)
    case error(String)
    case nothingToRestore
    case restored
}
