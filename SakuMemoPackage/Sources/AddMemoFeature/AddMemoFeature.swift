//
//  AddMemoFeature.swift
//  SakuMemo
//
//  Created by saki on 2025/05/03.
//

import ComposableArchitecture
import Foundation
import Repository
import RepositoryProtocol
import SharedModel

@Reducer
public struct AddMemoFeature: Sendable {
    public init() {}
    @ObservableState
    public struct State {
        public init() {}

        var text: String = ""
        var isSending: Bool = false
        var isTextField: Bool = true
        var memoList: [String] = []
        var memo = Memo(text: "")
        var remainingFreeMemos: Int = 3
        var isSubscribed: Bool = false
        var showLimitAlert: Bool = false
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case save
        case success([String])
        case failure
        case showTextField
        case addMemo(String)
        case gemini
        case error
        case successText(MemoAnalysisResult)
        case checkSubscriptionStatus
        case subscriptionStatusUpdated(isSubscribed: Bool, remainingMemos: Int)
        case showLimitAlert
        case dismissLimitAlert
        case foundationModels
        case foundationModelsExtractTasks
        case geminiExtractTasks
        case switchAi
        case switchAiTasks
    }

    @Dependency(\.geminiRepository) var geminiRepository
    @Dependency(\.swiftDataRepository) var swiftDataRepository
    @Dependency(\.subscriptionRepository) var subscriptionRepository
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .save:
                state.isSending = true
                let text = state.text
                return .run { send in
                    let canAdd = try await subscriptionRepository.canAddMemo()
                    print("🎯 AddMemoFeature.save: canAdd = \(canAdd)")
                    if canAdd {
                        print("🔄 incrementMemoCount を呼び出します")
                        try await subscriptionRepository.incrementMemoCount()
                        print("✅ incrementMemoCount 完了")
                        await send(.checkSubscriptionStatus)
                        await send(.switchAiTasks)
                    } else {
                        print("❌ 制限に達しました - アラートを表示")
                        await send(.showLimitAlert)
                    }
                }

            case .binding:
                return .none

            case let .success(result):
                state.isSending = false
                state.isTextField = false
                state.memoList = result

                return .none

            case .failure:
                state.isSending = false
                state.isTextField = false

                return .none

            case .showTextField:
                state.isTextField = true
                return .none

            case let .addMemo(text):
                let memo = Memo(text: text)
                state.memo = memo
                state.memoList.removeAll(where: { value in
                    value == text
                })
                return .run { send in
                    await send(.switchAi)
                }

            case .gemini:
                let text = state.memo.text
                return .run { send in
                    if let result = await geminiRepository.gemini(for: text) {
                        await send(.successText(result))
                    } else {
                        print("⚠️ Geminiの解析に失敗")
                        await send(.error)
                    }
                }

            case let .successText(result):
                state.memo.priorityValue = result.importance
                state.memo.category = result.category
                let memo = state.memo
                let newMemo = MemoSendable(
                    id: memo.id,
                    text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { _ in
                    try await swiftDataRepository.addMemo(newMemo: newMemo)
                }

            case .error:
                let memo = state.memo
                state.text = ""
                let delete = MemoSendable(
                    id: memo.id,
                    text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { _ in
                    try await swiftDataRepository.addMemo(newMemo: delete)
                }

            case .checkSubscriptionStatus:
                return .run { send in
                    // まずStoreKitで最新の課金状態を確認
                    @Dependency(\.storeKitRepository) var storeKitRepository
                    let storeKitSubscribed = try await storeKitRepository.checkSubscriptionStatus()

                    // ローカルデータベースと同期
                    let subscriptionData = try await subscriptionRepository.getUserSubscriptionData()
                    if subscriptionData.isSubscribed != storeKitSubscribed {
                        print("🔄 課金状態の同期: \(subscriptionData.isSubscribed) -> \(storeKitSubscribed)")
                        try await subscriptionRepository.updateSubscriptionStatus(isSubscribed: storeKitSubscribed)
                    }

                    // 最新の状態を取得
                    let updatedSubscriptionData = try await subscriptionRepository.getUserSubscriptionData()
                    let remainingMemos = try await subscriptionRepository.getRemainingFreeMemos()
                    await send(.subscriptionStatusUpdated(
                        isSubscribed: updatedSubscriptionData.isSubscribed,
                        remainingMemos: remainingMemos
                    ))
                }

            case let .subscriptionStatusUpdated(isSubscribed, remainingMemos):
                state.isSubscribed = isSubscribed
                state.remainingFreeMemos = remainingMemos
                return .none

            case .showLimitAlert:
                state.showLimitAlert = true
                return .none

            case .dismissLimitAlert:
                state.showLimitAlert = false
                return .none

            case .foundationModels:
                let text = state.memo.text
                return .run { send in
                    if #available(iOS 26.0, macOS 26.0, *) {
                        do {
                            let repo = FoundationModelRepository()
                            let result = try await repo.respond(userInput: text)
                            await send(.successText(result))
                        } catch {
                            print("⚠️Foundation Modelsの解析に失敗: \(error)")
                            await send(.gemini)
                        }
                    } else {
                        await send(.gemini)
                    }
                }

            case .foundationModelsExtractTasks:
                let text = state.memo.text
                return .run { send in
                    if #available(iOS 26.0, macOS 26.0, *) {
                        do {
                            let repo = FoundationModelRepository()
                            let result = try await repo.extractTasks(for: text)
                            await send(.success(result))
                        } catch {
                            print("⚠️Foundation Modelsの解析に失敗: \(error)")
                            await send(.gemini)
                        }
                    } else {
                        await send(.gemini)
                    }
                }

            case .geminiExtractTasks:
                let text = state.text
                return .run { send in
                    if let answer = await geminiRepository.geminiText(for: text) {
                        await send(.success(answer))
                    } else {
                        await send(.failure)
                    }
                }

            case .switchAi:
                if #available(iOS 26.0, macOS 26.0, *) {
                    return .run { send in
                        await send(.foundationModels)
                    }
                } else {
                    return .run { send in
                        await send(.gemini)
                    }
                }

            case .switchAiTasks:
                if #available(iOS 26.0, macOS 26.0, *) {
                    return .run { send in
                        do {
                            await send(.foundationModelsExtractTasks)
                        } catch {
                            print("⚠️ Foundation Modelsのタスク抽出に失敗: \(error)")
                            await send(.geminiExtractTasks)
                        }
                    }
                } else {
                    return .run { send in
                        await send(.geminiExtractTasks)
                    }
                }
            }
        }
    }
}
