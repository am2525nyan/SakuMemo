//
//  TaskView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

struct ArchiveMemoView: View {
    @Bindable var store: StoreOf<ArchiveMemoFeature>
    @Environment(\.scenePhase) var scenePhase
    @Query(filter: #Predicate<Memo>{$0.isArchived == true},sort: \Memo.createdAt, order: .reverse) var memos: [Memo]
    @FocusState var isFocused: Bool
    var body: some View {
        VStack {
            AddMemoComponent(
                tapped: {
                    store.send(.addMemo)
                },
                isFocused: _isFocused,
                text:$store.text
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
    MemoView(store:
            .init(initialState: MemoFeature.State(),
                  reducer: {
        MemoFeature()
    }))
}
