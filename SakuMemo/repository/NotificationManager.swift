//
//  NotificationManager.swift
//  SakuMemo
//
//  Created by saki on 2025/05/01.
//

import Foundation
import UserNotifications
import ComposableArchitecture

final class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("エラー！: \(error)")
            } else if granted {
                print("パーミッションあります！.")
            } else {
                print("失敗！")
            }
            
        }
    }
    
    func sendNotification(title: String, body: String, date: Date, id: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone.current
        
        let components = calendar.dateComponents(in: timeZone, from: date)
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        print("リクエスト完了")
        print(request)
        do{
            try await  UNUserNotificationCenter.current().add(request)
        } catch{
            print(error)
        }
    }
    
    func removeNotification(id: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers:[id])
    }
    
}

struct NotificationManagerKey: DependencyKey {
    static let liveValue = NotificationManager()
}
extension DependencyValues {
    var notificationManager: NotificationManager {
        get { self[NotificationManagerKey.self] }
        set { self[NotificationManagerKey.self] = newValue }
    }
}
