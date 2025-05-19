//
//  TaskReducer.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import Foundation
import ComposableArchitecture
import SharedModel
import Repository

@Reducer
public struct ArchiveMemoFeature : Sendable{
    public init() {}
    
    @ObservableState
    public  struct State{
        public init() {}
        var memo = Memo(text: "")
        var text: String = ""
    }
    public  enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addMemo
        case gemini
        case geminiSuccess(MemoAnalysisResult)
        case geminiError
        case deleteMemo(Memo)
        case deleteAllMemos
        case archiveMain(Memo)
    }
    @Dependency(\.swiftDataRepository) var swiftDataRepository
    @Dependency(\.geminiRepository) var geminiRepository
    
    public  var body: some ReducerOf <Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addMemo:
                let memo = Memo(text: state.text)
                state.memo = memo
                state.text = ""
                return .run { send in
                    
                    do{
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
                
            case .geminiSuccess(let result):
                state.memo.priorityValue = result.importance
                state.memo.category = result.category
                let memo = state.memo
                let newMemo = MemoSendable(
                    id: memo.id, text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { send in
                    try await swiftDataRepository.addMemo(newMemo: newMemo)
                }
                
            case .deleteAllMemos:
                return .run { send in
                    try await swiftDataRepository.deleteAllMemos()
                }
                
            case .binding(_):
                return .none
            case .geminiError:
                let memo = state.memo
                state.text = ""
                let newMemo = MemoSendable(
                    id: memo.id, text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { send in
                    try await swiftDataRepository.addMemo(newMemo: newMemo)
                }
            case .deleteMemo(let memo):
                let deleteMemo = MemoSendable(
                    id: memo.id, text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { send in
                    try await swiftDataRepository.deleteMemo(memo: deleteMemo)
                }
            case .archiveMain(let memo):
                memo.isArchived = false
                memo.date = nil
                return .none
            }
        }
    }
}
