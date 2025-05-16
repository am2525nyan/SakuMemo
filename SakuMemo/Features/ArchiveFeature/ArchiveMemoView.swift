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
                text:.constant("")
            )
            
            List {
                ForEach(memos) { memo in
                    MemoCellView(memo: memo)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.send(.deleteMemo(memo))
                            } label: {
                                Text("削除")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.send(.archiveMain(memo))
                                
                            } label: {
                                Text("戻す")
                            }
                            .tint(.orange)
                        }
                }
                
            }
            .listStyle(PlainListStyle())
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
