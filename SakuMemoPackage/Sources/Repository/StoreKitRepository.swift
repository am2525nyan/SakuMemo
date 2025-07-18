import Foundation
import StoreKit
import Dependencies
import RepositoryProtocol
import SharedModel

final class StoreKitRepository: StoreKitRepositoryProtocol, @unchecked Sendable {
    private let productIds = ["sakumemo_premium_monthly", "sakumemo_premium_yearly"]
    private var transactionUpdateTask: Task<Void, Never>?
    
    init() {
        startTransactionUpdateListener()
    }
    
    deinit {
        transactionUpdateTask?.cancel()
    }
    
    private func startTransactionUpdateListener() {
        transactionUpdateTask = Task {
            for await result in StoreKit.Transaction.updates {
                switch result {
                case .verified(let transaction):
                    await handleVerifiedTransaction(transaction)
                case .unverified:
                    print("Unverified transaction received")
                }
            }
        }
    }
    
    @MainActor
    private func handleVerifiedTransaction(_ transaction: StoreKit.Transaction) async {
        // トランザクションを完了
        await transaction.finish()
        
        // 必要に応じて購入状態を更新
        if productIds.contains(transaction.productID) {
            print("Premium subscription transaction verified: \(transaction.productID)")
        }
    }
    
    func loadProducts() async throws -> [StoreProduct] {
        let products = try await Product.products(for: productIds)
        return products.map { product in
            StoreProduct(
                id: product.id,
                displayName: product.displayName,
                description: product.description,
                price: product.displayPrice,
                priceValue: product.price
            )
        }
    }
    
    func purchaseProduct(_ product: StoreProduct) async throws -> PurchaseResult {
        guard let storeProduct = try await Product.products(for: [product.id]).first else {
            throw StoreError.productNotFound
        }
        
        let result = try await storeProduct.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                return .success
            case .unverified:
                throw StoreError.verificationFailed
            }
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            return .failed(StoreError.unknown)
        }
    }
    
    func restorePurchases() async throws {
        try await AppStore.sync()
    }
    
    func checkSubscriptionStatus() async throws -> Bool {
        for await result in StoreKit.Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if productIds.contains(transaction.productID) {
                    return true
                }
            case .unverified:
                continue
            }
        }
        return false
    }
}

public struct StoreKitRepositoryKey: DependencyKey {
    public static let liveValue: StoreKitRepositoryProtocol = StoreKitRepository()
}

public extension DependencyValues {
    var storeKitRepository: StoreKitRepositoryProtocol {
        get { self[StoreKitRepositoryKey.self] }
        set { self[StoreKitRepositoryKey.self] = newValue }
    }
}

enum StoreError: Error, LocalizedError {
    case productNotFound
    case verificationFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "商品が見つかりません"
        case .verificationFailed:
            return "購入の検証に失敗しました"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}
