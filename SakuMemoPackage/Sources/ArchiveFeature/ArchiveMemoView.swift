//
//  TaskView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import SwiftUI
import ComposableArchitecture
import SwiftData
import SharedModel
import Components

public struct ArchiveMemoView: View {
    public init(store: StoreOf<ArchiveMemoFeature>) {
        self.store = store
    }
    @Bindable var store: StoreOf<ArchiveMemoFeature>
    @Environment(\.scenePhase) var scenePhase
    @Query(filter: #Predicate<Memo>{$0.isArchived == true},sort: \Memo.createdAt, order: .reverse) var memos: [Memo]
    @FocusState var isFocused: Bool
    public var body: some View {
        VStack {
            AddMemoComponent(
                tapped: {
                    store.send(.addMemo)
                },
                text:$store.text, isFocused: _isFocused
            )
            ListComponent(memos: .constant(memos),
                          tapAction: {memo in
            }, swipeTrailingAction: { memo in
                store.send(.deleteMemo(memo))
            }, swipeLeadingAction: { memo in
                store.send(.archiveMain(memo))
            }, trailingText: "削除", leadingText: "戻す")
            
        }
    }
}

#Preview {
    ArchiveMemoView(store:
            .init(initialState: ArchiveMemoFeature.State(),
                  reducer: {
        ArchiveMemoFeature()
    }))
}
