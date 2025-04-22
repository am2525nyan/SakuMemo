//
//  TaskReducer.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MemoReducer {
    
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
                state.memos = [
                    Memo(text: "バナナ", category: .shopping,priority: .hot),
                    Memo(text: "Reducer書く", category: .todo, priority: .warm),
                    Memo(text: "旅行準備したい", category: .note, priority: .cold),
                    Memo(text: "りんご", category: .shopping,priority: .hot),
                    Memo(text: "インターンのDM返す！", category: .todo, priority: .hot),
                    Memo(text: "visionPro欲しい", category: .note, priority: .cold),
                    ]
                return .none
            }
        }
    }
}

