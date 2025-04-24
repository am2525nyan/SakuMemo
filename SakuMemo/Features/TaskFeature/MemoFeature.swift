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
        var memos = [Memo]()
        var memo = Memo(text: "")
        var text: String = ""
    }
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case refresh
        case refreshSuccess([Memo])
        case addMemo
        case gemini
        case geminiSuccess(MemoAnalysisResult)
        case deleteAllMemos
        case geminiError
        case deleteMemo(Memo)
    }
    @Dependency(\.swiftDataRepository) var swiftDataRepository
    @Dependency(\.geminiRepository) var geminiRepository
    
    var body: some ReducerOf <Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .refresh:
                return .run { send in
                    
                    do{
                        let memos =  try await swiftDataRepository.fetchMemos()
                        await send(.refreshSuccess(memos))
                    }
                    catch {
                        print(error)
                        
                    }
                }
                
            case .addMemo:
                let memo = Memo(text: state.text)
                state.memos.insert(memo, at: 0)
                state.memo = memo
                state.text = ""
                return .run { send in
                    
                    do{
                        await send(.gemini)
                    }
                    
                    
                }
            case .refreshSuccess(let memos):
                let sortMemos = memos.sorted { $0.createdAt > $1.createdAt }
                state.memos = sortMemos
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
                    await send(.refresh)
                }
            }
            return .none
        }
    }
}
