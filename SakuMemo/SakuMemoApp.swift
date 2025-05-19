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

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
       NotificationManager.shared.requestPermission()
       
       UNUserNotificationCenter.current().delegate = self

       return true
   }

}

@main
struct SakuMemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
        ContentView()
            .modelContainer(for: Memo.self)
          
        }
    }
}
