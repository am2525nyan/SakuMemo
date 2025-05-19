//
//  TabFeature.swift
//  SakuMemo
//
//  Created by saki on 2025/04/29.
//

import Foundation
import ComposableArchitecture
import MemoFeature
import ArchiveFeature

@Reducer
public struct AppFeature {
    public init() {}
    @ObservableState
    public struct State {
        public init() {}
        var memo = MemoFeature.State()
        var archive = ArchiveMemoFeature.State()
    }
    public enum Action{
        case memo(MemoFeature.Action)
        case archive(ArchiveMemoFeature.Action)
    }
    public var body: some ReducerOf<Self>{
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
