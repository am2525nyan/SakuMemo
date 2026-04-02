//
//  AppView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/29.
//

import ArchiveFeature
import ComposableArchitecture

// import GoogleMobileAds
import MemoFeature
import SettingsFeature
import SwiftUI
import Utils

public struct AppView: View {
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public let store: StoreOf<AppFeature>
    @State private var selectedTab = 0
    @State var text: String = ""

    public var body: some View {
        TabView(selection: $selectedTab) {
            Tab("ホーム", systemImage: "house.fill", value: 0) {
                VStack {
                    MemoView(store: store.scope(state: \.memo, action: \.memo))
                    //   bannerAdView
                }
                .dismissKeyboardOnTap()
            }
            Tab("アーカイブ", systemImage: "archivebox.fill", value: 1) {
                VStack {
                    ArchiveMemoView(store: store.scope(state: \.archive, action: \.archive))
                    //  bannerAdView
                }
                .dismissKeyboardOnTap()
            }
            Tab("設定", systemImage: "gearshape.fill", value: 2) {
                SettingsView(store: store.scope(state: \.settings, action: \.settings))
            }
            Tab(value: 3, role: .search) {
                Color.clear
            } label: {
                Label("新規メモ", systemImage: "square.and.pencil")
            }
        }
        .modifier(TabViewBottomAccessoryModifier(text: $text, store: store))
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 3 {
                selectedTab = 0
                store.send(.memo(.view(.showAddMemo)))
            }
        }
    }

//    private var bannerAdView: some View {
//        let adSize = currentOrientationAnchoredAdaptiveBanner(width: 375)
//        return BannerViewContainer(adSize)
//            .frame(width: adSize.size.width, height: adSize.size.height)
//    }
}

private struct TabViewBottomAccessoryModifier: ViewModifier {
    @Binding var text: String
    let store: StoreOf<AppFeature>

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .tabBarMinimizeBehavior(.onScrollDown)
                .tabViewBottomAccessory {
                    HStack {
                        TextField("メモを入力", text: $text)
                        Button(action: {
                            store.send(.memo(.view(.addMemo)))
                        }, label: {
                            ZStack {
                                Image(systemName: "paperplane.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.mainColor)
                            }
                        })
                    }
                    .padding(.horizontal, 20)
                }
        } else {
            content
        }
    }
}

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
