//
//  TaskReducer.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import Foundation
import ComposableArchitecture

@Reducer
struct TaskReducer {
    
    @ObservableState
    struct State{
        var memos = [Memo]()
    }
    enum Action {
        case refresh
    }
    @Dependency(\.swiftDataRepository) var swiftDataRepository
    var body: some ReducerOf <Self> {
        Reduce { state, action in
            switch action {
            case .refresh:
                state.memos = []
                return .none
            }
        }
    }
}

