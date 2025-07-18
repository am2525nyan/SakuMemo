import Foundation
import SharedModel

public protocol SubscriptionRepositoryProtocol: Sendable {
    func getUserSubscriptionData() async throws -> UserSubscriptionData
    func updateSubscription(_ subscription: UserSubscription) async throws
    func canAddMemo() async throws -> Bool
    func incrementMemoCount() async throws
    func getRemainingFreeMemos() async throws -> Int
    func updateSubscriptionStatus(isSubscribed: Bool) async throws
}

public protocol StoreKitRepositoryProtocol: Sendable {
    func loadProducts() async throws -> [StoreProduct]
    func purchaseProduct(_ product: StoreProduct) async throws -> PurchaseResult
    func restorePurchases() async throws
    func checkSubscriptionStatus() async throws -> Bool
}

public struct StoreProduct: Identifiable, Sendable {
    public let id: String
    public let displayName: String
    public let description: String
    public let price: String
    public let priceValue: Decimal

    public init(id: String, displayName: String, description: String, price: String, priceValue: Decimal) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.price = price
        self.priceValue = priceValue
    }
}

public enum PurchaseResult: Sendable {
    case success
    case cancelled
    case failed(Error)
    case pending
}
