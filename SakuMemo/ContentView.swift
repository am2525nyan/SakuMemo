//
//  ContentView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import AppFeature
import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    var body: some View {
        AppView(
            store:
            .init(
                initialState:
                AppFeature.State(),
                reducer: {
                    AppFeature()
                }
            )
        )
    }
}

#Preview {
    ContentView()
}
