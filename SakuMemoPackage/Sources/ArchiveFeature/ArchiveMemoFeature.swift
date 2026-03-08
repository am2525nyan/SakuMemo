//
//  ArchiveMemoFeature.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import ComposableArchitecture
import Foundation
import Repository
import SharedModel

@Reducer
public struct ArchiveMemoFeature: Sendable {
    public init() {}

    @ObservableState
    public struct State {
        public init() {}

        var memo = Memo(text: "")
        var text: String = ""
    }

    public enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(View)
        case gemini
        case geminiSuccess(MemoAnalysisResult)
        case geminiError
        case deleteAllMemos

        public enum View {
            case addMemo
            case deleteMemo(Memo)
            case archiveMain(Memo)
        }
    }

    @Dependency(\.swiftDataRepository) var swiftDataRepository
    @Dependency(\.geminiRepository) var geminiRepository

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .view(.addMemo):
                let memo = Memo(text: state.text)
                state.memo = memo
                state.text = ""
                return .run { send in
                    do {
                        await send(.gemini)
                    }
                }

            case .gemini:
                let text = state.memo.text
                return .run { send in
                    if let result = await geminiRepository.gemini(for: text) {
                        await send(.geminiSuccess(result))
                    } else {
                        print("⚠️ Geminiの解析に失敗")
                        await send(.geminiError)
                    }
                }

            case let .geminiSuccess(result):
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

            case .deleteAllMemos:
                return .run { _ in
                    try await swiftDataRepository.deleteAllMemos()
                }

            case .binding:
                return .none

            case .geminiError:
                let memo = state.memo
                state.text = ""
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

            case let .view(.deleteMemo(memo)):
                let deleteMemo = MemoSendable(
                    id: memo.id,
                    text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { _ in
                    try await swiftDataRepository.deleteMemo(memo: deleteMemo)
                }

            case let .view(.archiveMain(memo)):
                memo.isArchived = false
                memo.date = nil
                return .none
            }
        }
    }
}
