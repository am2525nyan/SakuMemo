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
    }
    enum Action {
        case refresh
        case refreshSuccess([Memo])
        case addMemo(String)
    }
    @Dependency(\.swiftDataRepository) var swiftDataRepository
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
                
                return .run { send in
                 
                        do{
                            try await swiftDataRepository.addMemo(newMemo: memo)
                        }
                        catch {
                            print(error)
                            
                        }
                    
                }
            case .refreshSuccess(let memos):
                state.memos = memos
            }
            return .none
        }
    }
}

