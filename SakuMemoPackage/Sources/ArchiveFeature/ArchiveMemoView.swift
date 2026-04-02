//
//  ArchiveMemoView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import Components
import ComposableArchitecture
import SharedModel
import SwiftData
import SwiftUI

@ViewAction(for: ArchiveMemoFeature.self)
public struct ArchiveMemoView: View {
    public init(store: StoreOf<ArchiveMemoFeature>) {
        self.store = store
    }

    @Bindable public var store: StoreOf<ArchiveMemoFeature>
    @Environment(\.scenePhase) var scenePhase
    @Query(filter: #Predicate<Memo> { $0.isArchived == true }, sort: \Memo.createdAt, order: .reverse) var memos: [Memo]
    @FocusState var isFocused: Bool
    public var body: some View {
        VStack {
            ListComponent(
                memos: .constant(memos),
                tapAction: { _ in
                },
                swipeTrailingAction: { memo in
                    send(.deleteMemo(memo))
                },
                swipeLeadingAction: { memo in
                    send(.archiveMain(memo))
                },
                trailingText: "削除",
                leadingText: "戻す"
            )
        }
    }
}

#Preview {
    ArchiveMemoView(
        store:
        .init(
            initialState:
            ArchiveMemoFeature.State(),
            reducer: {
                ArchiveMemoFeature()
            }
        )
    )
}
