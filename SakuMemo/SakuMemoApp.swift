//
//  SakuMemoApp.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import AdSupport
import FirebaseAppCheck
import FirebaseCore
import GoogleMobileAds
import Repository
import SharedModel
import StoreKit
import SwiftData
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var transactionUpdateTask: Task<Void, Never>?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let providerFactory = SakuMemoAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        FirebaseApp.configure()

        MobileAds.shared.start()
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["3cb82a328b7b6c6a873368eeeffa4aa8"]

        NotificationManager.shared.requestPermission()

        UNUserNotificationCenter.current().delegate = self

        // StoreKitトランザクション更新の監視を開始
        startTransactionUpdateListener()

        return true
    }

    private func startTransactionUpdateListener() {
        transactionUpdateTask = Task {
            for await result in StoreKit.Transaction.updates {
                switch result {
                case let .verified(transaction):
                    await handleTransaction(transaction)

                case .unverified:
                    print("Unverified transaction received")
                }
            }
        }
    }

    private func handleTransaction(_ transaction: StoreKit.Transaction) async {
        // トランザクションを完了
        await transaction.finish()
        print("Transaction finished: \(transaction.productID)")
    }

    deinit {
        transactionUpdateTask?.cancel()
    }
}

class SakuMemoAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if DEBUG
            // 開発環境ではDebugプロバイダーを使用
            return AppCheckDebugProvider(app: app)
        #else
            // 本番環境ではApp Attestationを使用
            return AppAttestProvider(app: app)
        #endif
    }
}

@main
struct SakuMemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Memo.self, UserSubscription.self])
        }
    }
}
