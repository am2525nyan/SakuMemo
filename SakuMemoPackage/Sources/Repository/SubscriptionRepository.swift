import Foundation
import SwiftData
import Dependencies
import RepositoryProtocol
import SharedModel

struct SubscriptionRepository: SubscriptionRepositoryProtocol, Sendable {
    @Dependency(\.database) private var database
    
    func getUserSubscriptionData() async throws -> UserSubscriptionData {
        return try await MainActor.run {
            let context = database.context
            
            let descriptor = FetchDescriptor<UserSubscription>()
            let subscriptions = try context.fetch(descriptor)
            
            let subscription: UserSubscription
            if let existingSubscription = subscriptions.first {
                subscription = existingSubscription
                print("📊 既存のサブスクリプション取得: ID=\(subscription.id), dailyCount=\(subscription.dailyMemoCount)")
            } else {
                let newSubscription = UserSubscription()
                context.insert(newSubscription)
                try context.save()
                subscription = newSubscription
                print("🆕 新しいサブスクリプション作成: ID=\(subscription.id), dailyCount=\(subscription.dailyMemoCount)")
            }
            
            return UserSubscriptionData(from: subscription)
        }
    }
    
    func updateSubscription(_ subscription: UserSubscription) async throws {
        let subscriptionId = subscription.id
        try await MainActor.run {
            let context = database.context
            let descriptor = FetchDescriptor<UserSubscription>(predicate: #Predicate<UserSubscription> { $0.id == subscriptionId })
            let subscriptions = try context.fetch(descriptor)
            
            if let existingSubscription = subscriptions.first {
                existingSubscription.updatedAt = Date()
                try context.save()
            }
        }
    }
    
    func canAddMemo() async throws -> Bool {
        let subscriptionData = try await getUserSubscriptionData()
        let canAdd = subscriptionData.canAddMemo
        
        // デバッグ用ログ
        print("🔍 制限チェック: isSubscribed=\(subscriptionData.isSubscribed), dailyCount=\(subscriptionData.dailyMemoCount), canAdd=\(canAdd)")
        
        return canAdd
    }
    
    func incrementMemoCount() async throws {
        try await MainActor.run {
            let context = database.context
            let descriptor = FetchDescriptor<UserSubscription>()
            let subscriptions = try context.fetch(descriptor)
            
            if let subscription = subscriptions.first {
                print("📈 カウント増加前: \(subscription.dailyMemoCount)")
                subscription.incrementMemoCount()
                print("📈 カウント増加後: \(subscription.dailyMemoCount)")
                try context.save()
                print("✅ データベース保存完了")
            } else {
                print("❌ UserSubscriptionが見つかりません")
            }
        }
    }
    
    func getRemainingFreeMemos() async throws -> Int {
        let subscriptionData = try await getUserSubscriptionData()
        return subscriptionData.remainingFreeMemos
    }
    
    func updateSubscriptionStatus(isSubscribed: Bool) async throws {
        try await MainActor.run {
            let context = database.context
            let descriptor = FetchDescriptor<UserSubscription>()
            let subscriptions = try context.fetch(descriptor)
            
            if let subscription = subscriptions.first {
                print("🔄 サブスクリプション状態更新: \(subscription.isSubscribed) -> \(isSubscribed)")
                subscription.updateSubscriptionStatus(isSubscribed: isSubscribed, productId: "premium")
                try context.save()
                print("✅ サブスクリプション状態更新完了")
            } else {
                print("❌ UserSubscriptionが見つかりません")
            }
        }
    }
}

public struct SubscriptionRepositoryKey: DependencyKey {
    public static let liveValue: SubscriptionRepositoryProtocol = SubscriptionRepository()
}

public extension DependencyValues {
    var subscriptionRepository: SubscriptionRepositoryProtocol {
        get { self[SubscriptionRepositoryKey.self] }
        set { self[SubscriptionRepositoryKey.self] = newValue }
    }
}
