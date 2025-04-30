//
//  SakuMemoApp.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

@main
struct SakuMemoApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(store:
                    .init(
                        initialState:
                            AppFeature.State(),
                        reducer: {
                            AppFeature()
                        }
                    )
            )
            .modelContainer(for: Memo.self)
        }
    }
}
