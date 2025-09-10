//
//  AppFeature.swift
//  SakuMemo
//
//  Created by saki on 2025/04/29.
//

import ArchiveFeature
import ComposableArchitecture
import Foundation
import MemoFeature

@Reducer
public struct AppFeature {
    public init() {}
    @ObservableState
    public struct State {
        public init() {}

        var memo = MemoFeature.State()
        var archive = ArchiveMemoFeature.State()
        var settings = SettingsFeature.State()
    }

    public enum Action {
        case memo(MemoFeature.Action)
        case archive(ArchiveMemoFeature.Action)
        case settings(SettingsFeature.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.memo, action: \.memo) {
            MemoFeature()
        }
        Scope(state: \.archive, action: \.archive) {
            ArchiveMemoFeature()
        }
        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }
        Reduce { _, action in
            switch action {
            case .memo:
                return .none

            case .archive:
                return .none

            case .settings:
                return .none
            }
        }
    }
}

import SettingsFeature
