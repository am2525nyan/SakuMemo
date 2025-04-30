//
//  TaskReducer.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MemoFeature {
    
    @ObservableState
    struct State{
        var memo = Memo(text: "")
        var text: String = ""
    }
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addMemo
        case gemini
        case geminiSuccess(MemoAnalysisResult)
        case geminiError
        case deleteMemo(Memo)
        case deleteAllMemos
        case archive(Memo)
        case onAppear
    }
    @Dependency(\.swiftDataRepository) var swiftDataRepository
    @Dependency(\.geminiRepository) var geminiRepository
    
    var body: some ReducerOf <Self> {
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
                
                return .run { send in
                    try await swiftDataRepository.addMemo(newMemo: memo)
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
                return .run { send in
                    try await swiftDataRepository.addMemo(newMemo: memo)
                }
            case .deleteMemo(let memo):
                return .run { send in
                    try await swiftDataRepository.deleteMemo(memo: memo)
                }
            case .archive(let memo):
                memo.isArchived = true
                return .none
            case .onAppear:
                return .run { send in
                    try await swiftDataRepository.archiveMemos()
                }
            }
        }
    }
}
