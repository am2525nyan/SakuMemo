//
//  SakuMemoApp.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import SwiftUI
import ComposableArchitecture

@main
struct SakuMemoApp: App {
    var body: some Scene {
        WindowGroup {
            MemoView(store:
                       .init(initialState: MemoReducer.State(),
                             reducer: {
                   MemoReducer()
               }))
        }
    }
}
