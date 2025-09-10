//
//  AppView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/29.
//

import ArchiveFeature
import ComposableArchitecture
import MemoFeature
import SwiftUI
import Utils

public struct AppView: View {
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public let store: StoreOf<AppFeature>

    public var body: some View {
        TabView {
            MemoView(store: store.scope(state: \.memo, action: \.memo))
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
                .dismissKeyboardOnTap()

            ArchiveMemoView(store: store.scope(state: \.archive, action: \.archive))
                .tabItem {
                    Image(systemName: "archivebox.fill")
                    Text("アーカイブ")
                }
                .dismissKeyboardOnTap()

            SettingsView(store: store.scope(state: \.settings, action: \.settings))
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
        }
    }
}

import SettingsFeature

#Preview {
    AppView(
        store:
        .init(
            initialState: AppFeature.State(),
            reducer: {
                AppFeature()
            }
        )
    )
}
