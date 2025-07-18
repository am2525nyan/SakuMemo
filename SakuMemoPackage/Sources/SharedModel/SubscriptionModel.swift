import Foundation
import SwiftData

@Model
public final class UserSubscription {
    @Attribute(.unique) public var id: UUID
    public var isSubscribed: Bool
    public var subscriptionStartDate: Date?
    public var subscriptionEndDate: Date?
    public var productId: String?
    public var dailyMemoCount: Int
    public var lastResetDate: Date
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        isSubscribed: Bool = false,
        subscriptionStartDate: Date? = nil,
        subscriptionEndDate: Date? = nil,
        productId: String? = nil,
        dailyMemoCount: Int = 0,
        lastResetDate: Date = Calendar.current.startOfDay(for: Date()),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.isSubscribed = isSubscribed
        self.subscriptionStartDate = subscriptionStartDate
        self.subscriptionEndDate = subscriptionEndDate
        self.productId = productId
        self.dailyMemoCount = dailyMemoCount
        self.lastResetDate = lastResetDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension UserSubscription {
    public static let freeUserDailyLimit = 3
    
    public var canAddMemo: Bool {
        resetDailyCountIfNeeded()
        return isSubscribed || dailyMemoCount < Self.freeUserDailyLimit
    }
    
    public var remainingFreeMemos: Int {
        resetDailyCountIfNeeded()
        return isSubscribed ? -1 : max(0, Self.freeUserDailyLimit - dailyMemoCount)
    }
    
    public func incrementMemoCount() {
        resetDailyCountIfNeeded()
        let oldCount = dailyMemoCount
        dailyMemoCount += 1
        updatedAt = Date()
        print("📝 UserSubscription.incrementMemoCount: \(oldCount) -> \(dailyMemoCount)")
    }
    
    public func resetDailyCountIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        if lastResetDate < today {
            print("🔄 日次リセット実行: \(dailyMemoCount) -> 0")
            dailyMemoCount = 0
            lastResetDate = today
            updatedAt = Date()
        }
    }
    
    public func updateSubscriptionStatus(isSubscribed: Bool, productId: String? = nil) {
        self.isSubscribed = isSubscribed
        self.productId = productId
        
        if isSubscribed {
            subscriptionStartDate = Date()
            subscriptionEndDate = nil
        } else {
            subscriptionEndDate = Date()
        }
        
        updatedAt = Date()
    }
}

public struct UserSubscriptionData: Sendable {
    public let id: UUID
    public let isSubscribed: Bool
    public let subscriptionStartDate: Date?
    public let subscriptionEndDate: Date?
    public let productId: String?
    public let dailyMemoCount: Int
    public let lastResetDate: Date
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(from subscription: UserSubscription) {
        self.id = subscription.id
        self.isSubscribed = subscription.isSubscribed
        self.subscriptionStartDate = subscription.subscriptionStartDate
        self.subscriptionEndDate = subscription.subscriptionEndDate
        self.productId = subscription.productId
        self.dailyMemoCount = subscription.dailyMemoCount
        self.lastResetDate = subscription.lastResetDate
        self.createdAt = subscription.createdAt
        self.updatedAt = subscription.updatedAt
    }
    
    public var canAddMemo: Bool {
        return isSubscribed || dailyMemoCount < UserSubscription.freeUserDailyLimit
    }
    
    public var remainingFreeMemos: Int {
        return isSubscribed ? -1 : max(0, UserSubscription.freeUserDailyLimit - dailyMemoCount)
    }
    
    public func toUserSubscription() -> UserSubscription {
        let subscription = UserSubscription()
        subscription.id = self.id
        subscription.isSubscribed = self.isSubscribed
        subscription.subscriptionStartDate = self.subscriptionStartDate
        subscription.subscriptionEndDate = self.subscriptionEndDate
        subscription.productId = self.productId
        subscription.dailyMemoCount = self.dailyMemoCount
        subscription.lastResetDate = self.lastResetDate
        subscription.createdAt = self.createdAt
        subscription.updatedAt = self.updatedAt
        return subscription
    }
}

public enum SubscriptionError: Error, LocalizedError {
    case dailyLimitExceeded
    case subscriptionRequired
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .dailyLimitExceeded:
            return "1日の無料メモ作成上限（3回）に達しました"
        case .subscriptionRequired:
            return "この機能を使用するには課金が必要です"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}
