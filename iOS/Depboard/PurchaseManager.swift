import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let productID = "com.shimondeitel.depboard.pro"

    @Published var isPurchased: Bool = false
    @Published var product: Product?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var updateListenerTask: Task<Void, Error>?

    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProduct()
            await refreshPurchasedStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
        } catch {
            errorMessage = "Could not load product: \(error.localizedDescription)"
        }
    }

    func purchase() async {
        guard let product else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    isPurchased = true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await refreshPurchasedStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshPurchasedStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.productID {
                isPurchased = true
                return
            }
        }
        isPurchased = false
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.refreshPurchasedStatus()
                }
            }
        }
    }
}
