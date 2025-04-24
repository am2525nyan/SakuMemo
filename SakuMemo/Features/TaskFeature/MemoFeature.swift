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
        var geminiAnswer = ""
    }
    enum Action {
        case refresh
        case refreshSuccess([Memo])
        case addMemo(String)
        case gemini
        case geminiSuccess(String)
        case deleteAllMemo
    }
    @Dependency(\.swiftDataRepository) var swiftDataRepository
    @Dependency(\.geminiRepository) var geminiRepository
    
    var body: some ReducerOf <Self> {
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
                
            case .addMemo(let text):
                let memo = Memo(text: text)
                state.memos.insert(memo, at: 0)
                state.memo = memo
                
                return .run { send in
                    
                    do{
                        await send(.gemini)
                    }
                    
                    
                }
            case .refreshSuccess(let memos):
                state.memos = memos
            case .gemini:
                let text = state.memo.text
                return .run { send in
                    do{
                        let answer = await geminiRepository.gemini(for:text)
                        await send(.geminiSuccess(answer))
                        
                    }
                }
                
            case .geminiSuccess(let text):
                state.geminiAnswer = text
                state.memo.priorityValue = Double(text) ?? 1
                let memo = state.memo
                return .run { send in
                    try await swiftDataRepository.addMemo(newMemo: memo)
                }
                
            case .deleteAllMemo:
                return .run { send in
                    try await swiftDataRepository.deleteAllMemos()
                }
                
            }
            return .none
        }
    }
}
