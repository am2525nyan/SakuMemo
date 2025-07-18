//
//  SakuMemoApp.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import SwiftUI
import SwiftData
import Repository
import SharedModel
import StoreKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var transactionUpdateTask: Task<Void, Never>?

   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
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
               case .verified(let transaction):
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
