//
//  BannerViewContainer.swift
//  SakuMemoPackage
//
//  Created by saki on 2025/09/06.
//

import Foundation
import GoogleMobileAds
import SwiftUI

public struct BannerViewContainer: UIViewRepresentable {
    public typealias UIViewType = BannerView

    let adSize: AdSize

    public init(_ adSize: AdSize) {
        self.adSize = adSize
    }

    public func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        #if DEBUG
            banner.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        #else
            banner.adUnitID = "ca-app-pub-2163424558440055/4876941948"
        #endif

        banner.load(Request())

        return banner
    }

    public func updateUIView(_ uiView: BannerView, context: Context) {}
}
