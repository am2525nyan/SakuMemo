//
//  MemoFeature.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import AddMemoFeature
import ComposableArchitecture
import Foundation
import MemoDetailFeature
import Repository
import SharedModel
import SubscriptionFeature

@Reducer
public struct MemoFeature: Sendable {
    public init() {}

    @ObservableState
    public struct State {
        public init() {}

        var memo = Memo(text: "")
        var text: String = ""

        @Presents var detail: MemoDetailFeature.State?
        @Presents var add: AddMemoFeature.State?
        @Presents var subscription: SubscriptionFeature.State?
        var isShowDetails: Bool = false
        var isShowAdd: Bool = false
        var isShowPopup: Bool = false
        var isShowSubscription: Bool = false
    }

    public enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(View)
        case gemini
        case success(MemoAnalysisResult)
        case error
        case deleteAllMemos

        case showPopup
        case closePopup
        case foundationModels
        case switchAi

        case presentMemoDetail(PresentationAction<MemoDetailFeature.Action>)
        case presentAddMemo(PresentationAction<AddMemoFeature.Action>)
        case presentSubscription(PresentationAction<SubscriptionFeature.Action>)
        public enum View {
            case onAppear
            case addMemo
            case deleteMemo(Memo)
            case archive(Memo)
            case showDetail(Memo)
            case showAddMemo
            case showSubscription
        }
    }

    @Dependency(\.swiftDataRepository) var swiftDataRepository
    @Dependency(\.geminiRepository) var geminiRepository
    @Dependency(\.notificationManager) var notificationManager
    @Dependency(\.continuousClock) var clock

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                return .run { _ in
                    do {
                        try await swiftDataRepository.automaticPriorityValues()
                    } catch {
                        print("自動処理失敗")
                    }
                }

            case let .view(.deleteMemo(memo)):
                let new = MemoSendable(
                    id: memo.id,
                    text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { _ in
                    try await swiftDataRepository.deleteMemo(memo: new)
                }

            case let .view(.archive(memo)):
                memo.isArchived = true
                return .none

            case let .view(.showDetail(memo)):
                state.isShowDetails = true
                state.detail = MemoDetailFeature.State(memo: memo)
                return .none

            case .view(.addMemo):
                let memo = Memo(text: state.text)
                state.memo = memo
                state.text = ""
                return .run { send in
                    do {
                        await send(.switchAi)
                    }
                }

            case .gemini:
                let text = state.memo.text
                return .run { send in
                    if let result = await geminiRepository.gemini(for: text) {
                        await send(.success(result))
                    } else {
                        print("⚠️ Geminiの解析に失敗")
                        await send(.error)
                    }
                }

            case .foundationModels:
                let text = state.memo.text
                return .run { send in
                    if #available(iOS 26.0, macOS 26.0, *) {
                        do {
                            let repo = FoundationModelRepository()
                            let result = try await repo.respond(userInput: text)
                            await send(.success(result))
                        } catch {
                            print("⚠️Foundation Modelsの解析に失敗: \(error)")
                            await send(.gemini)
                        }
                    } else {
                        // Fallback on earlier versions
                        await send(.gemini)
                    }
                }

            case let .success(result):
                state.memo.priorityValue = result.importance
                state.memo.category = result.category
                let memo = state.memo
                let new = MemoSendable(
                    id: memo.id,
                    text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { send in
                    try await swiftDataRepository.addMemo(newMemo: new)
                    await send(.showPopup)
                }

            case .deleteAllMemos:
                return .run { _ in
                    try await swiftDataRepository.deleteAllMemos()
                }

            case .binding:
                return .none

            case .error:
                let memo = state.memo
                state.text = ""
                let new = MemoSendable(
                    id: memo.id,
                    text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { _ in
                    try await swiftDataRepository.addMemo(newMemo: new)
                }

            case .view(.showAddMemo):
                state.isShowAdd = true
                state.add = AddMemoFeature.State()
                return .none

            case .showPopup:
                state.isShowPopup = true
                return .run { send in
                    try await clock.sleep(for: .seconds(2))
                    await send(.closePopup)
                }

            case .closePopup:
                state.isShowPopup = false
                return .none

            case .view(.showSubscription):
                state.isShowSubscription = true
                state.subscription = SubscriptionFeature.State()
                return .none

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

            case .presentMemoDetail:
                return .none

            case .presentAddMemo:
                return .none

            case .presentSubscription:
                return .none
            }
        }
        .ifLet(\.$detail, action: \.presentMemoDetail) {
            MemoDetailFeature()
        }
        .ifLet(\.$add, action: \.presentAddMemo) {
            AddMemoFeature()
        }
        .ifLet(\.$subscription, action: \.presentSubscription) {
            SubscriptionFeature()
        }
    }
}
