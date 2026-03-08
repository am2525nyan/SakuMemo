//
//  AppView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/29.
//

import ArchiveFeature
import ComposableArchitecture
import GoogleMobileAds
import MemoFeature
import SettingsFeature
import SwiftUI
import Utils

public struct AppView: View {
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public let store: StoreOf<AppFeature>

    public var body: some View {
        if #available(iOS 26.0, *) {
            TabView {
                VStack {
                    MemoView(store: store.scope(state: \.memo, action: \.memo))
                    bannerAdView
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
                .dismissKeyboardOnTap()

                VStack {
                    ArchiveMemoView(store: store.scope(state: \.archive, action: \.archive))
                    bannerAdView
                }
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
            .tabBarMinimizeBehavior(.onScrollDown)

        } else {
            TabView {
                VStack {
                    MemoView(store: store.scope(state: \.memo, action: \.memo))
                    bannerAdView
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
                .dismissKeyboardOnTap()

                VStack {
                    ArchiveMemoView(store: store.scope(state: \.archive, action: \.archive))
                    bannerAdView
                }
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

    private var bannerAdView: some View {
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: 375)
        return BannerViewContainer(adSize)
            .frame(width: adSize.size.width, height: adSize.size.height)
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
