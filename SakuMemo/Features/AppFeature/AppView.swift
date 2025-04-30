
//  TabView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/29.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>
    var body: some View {
        TabView{
            MemoView(store: store.scope(state: \.memo, action: \.memo))
                .tabItem{
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
            
            ArchiveMemoView(store: store.scope(state: \.archive, action: \.archive))
                .tabItem{
                    Image(systemName: "house.fill")
                    Text("アーカイブ")
                }
        }
    }
}

#Preview {
    AppView(store:
            .init(
                initialState: AppFeature.State(),
                reducer: {
                    AppFeature()
                }
            )
    )
}
