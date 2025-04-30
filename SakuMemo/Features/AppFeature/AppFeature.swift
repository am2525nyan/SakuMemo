//
//  TabFeature.swift
//  SakuMemo
//
//  Created by saki on 2025/04/29.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var memo = MemoFeature.State()
        var archive = ArchiveMemoFeature.State()
    }
    enum Action{
        case memo(MemoFeature.Action)
        case archive(ArchiveMemoFeature.Action)
    }
    var body: some ReducerOf<Self>{
        Scope(state: \.memo, action: \.memo){
            MemoFeature()
        }
        Scope(state: \.archive, action: \.archive){
            ArchiveMemoFeature()
        }
        Reduce { state, action in
            switch action {
            case .memo:
                return .none
            case .archive:
                return .none
            }
        }
    }
    
}
