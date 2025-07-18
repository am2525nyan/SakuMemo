import Foundation
import ComposableArchitecture
import SharedModel
import Repository
import RepositoryProtocol
import StoreKit

@Reducer
public struct SubscriptionFeature: Sendable {
    public init() {}
    
    @ObservableState
    public struct State {
        public init() {}
        var isSubscribed: Bool = false
        var products: [StoreProduct] = []
        var isLoading: Bool = false
        var errorMessage: String?
        var showError: Bool = false
        var remainingFreeMemos: Int = 3
        var subscription: UserSubscriptionData?
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case loadProducts
        case productsLoaded([StoreProduct])
        case purchaseProduct(StoreProduct)
        case purchaseCompleted
        case purchaseFailed(String)
        case restorePurchases
        case checkSubscriptionStatus
        case subscriptionStatusUpdated(UserSubscriptionData)
        case dismissError
        case onAppear
    }
    
    @Dependency(\.subscriptionRepository) var subscriptionRepository
    @Dependency(\.storeKitRepository) var storeKitRepository
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
                
            case .onAppear:
                return .run { send in
                    await send(.checkSubscriptionStatus)
                    await send(.loadProducts)
                }
                
            case .loadProducts:
                state.isLoading = true
                return .run { send in
                    do {
                        let products = try await storeKitRepository.loadProducts()
                        await send(.productsLoaded(products))
                    } catch {
                        await send(.purchaseFailed(error.localizedDescription))
                    }
                }
                
            case .productsLoaded(let products):
                state.isLoading = false
                state.products = products
                return .none
                
            case .purchaseProduct(let product):
                state.isLoading = true
                return .run { send in
                    do {
                        let result = try await storeKitRepository.purchaseProduct(product)
                        switch result {
                        case .success:
                            await send(.purchaseCompleted)
                        case .cancelled:
                            await send(.purchaseFailed("購入がキャンセルされました"))
                        case .failed(let error):
                            await send(.purchaseFailed(error.localizedDescription))
                        case .pending:
                            await send(.purchaseFailed("購入処理が保留中です"))
                        }
                    } catch {
                        await send(.purchaseFailed(error.localizedDescription))
                    }
                }
                
            case .purchaseCompleted:
                state.isLoading = false
                return .run { send in
                    // StoreKitで課金状態を確認
                    let isSubscribed = try await storeKitRepository.checkSubscriptionStatus()
                    print("💰 課金完了: isSubscribed = \(isSubscribed)")
                    
                    // ローカルデータベースのサブスクリプション状態を更新
                    try await subscriptionRepository.updateSubscriptionStatus(isSubscribed: isSubscribed)
                    
                    // 状態を更新
                    await send(.checkSubscriptionStatus)
                }
                
            case .purchaseFailed(let message):
                state.isLoading = false
                state.errorMessage = message
                state.showError = true
                return .none
                
            case .restorePurchases:
                state.isLoading = true
                return .run { send in
                    do {
                        try await storeKitRepository.restorePurchases()
                        let _ = try await storeKitRepository.checkSubscriptionStatus()
                        // Update subscription status and check
                        await send(.checkSubscriptionStatus)
                    } catch {
                        await send(.purchaseFailed(error.localizedDescription))
                    }
                }
                
            case .checkSubscriptionStatus:
                return .run { send in
                    let subscriptionData = try await subscriptionRepository.getUserSubscriptionData()
                    await send(.subscriptionStatusUpdated(subscriptionData))
                }
                
            case .subscriptionStatusUpdated(let subscription):
                state.isSubscribed = subscription.isSubscribed
                state.remainingFreeMemos = subscription.remainingFreeMemos
                state.subscription = subscription
                state.isLoading = false
                return .none
                
            case .dismissError:
                state.showError = false
                state.errorMessage = nil
                return .none
            }
        }
    }
}