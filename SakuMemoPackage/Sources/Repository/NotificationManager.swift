//
//  NotificationManager.swift
//  SakuMemo
//
//  Created by saki on 2025/05/01.
//

import Foundation
import UserNotifications
import ComposableArchitecture

public final class NotificationManager:Sendable {
    public static let shared = NotificationManager()
    public init() {}
    public func requestPermission() {
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
    
    public func sendNotification(title: String, body: String, date: Date, id: String) async throws {
        let content = UNMutableNotificationContent()
        
        if #available(iOS 18.4, macOS 15.4, *) {
            let image = try await ImageCreatorRepository.shared.generateImage(text: body)
            if let image = image {
                let fileURL = try ImageCreatorRepository.shared.saveCGImageToTemporaryFile(image)
                let attachment = try UNNotificationAttachment(identifier: "generatedImage", url: fileURL, options: nil)
                content.attachments = [attachment]
            }
        }
        
        content.title = title
        content.body = body
        
        
        let calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone.current
        
        let components = calendar.dateComponents(in: timeZone, from: date)
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        print("リクエスト完了")
        do{
            try await  UNUserNotificationCenter.current().add(request)
        } catch{
            print(error)
        }
    }
    
    public func removeNotification(id: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers:[id])
    }
    
}

public struct NotificationManagerKey: DependencyKey {
    public static let liveValue = NotificationManager()
}
public extension DependencyValues {
    var notificationManager: NotificationManager {
        get { self[NotificationManagerKey.self] }
        set { self[NotificationManagerKey.self] = newValue }
    }
}
