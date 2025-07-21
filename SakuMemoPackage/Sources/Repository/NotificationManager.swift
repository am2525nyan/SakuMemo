//
//  NotificationManager.swift
//  SakuMemo
//
//  Created by saki on 2025/05/01.
//

import ComposableArchitecture
import Foundation
import UserNotifications

public final class NotificationManager: Sendable {
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
            dateMatching: components, repeats: false
        )

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        print("リクエスト完了")
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print(error)
        }
    }

    public func removeNotification(id: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    // 3段階リマインド通知を設定
    public func scheduleReminderNotifications(for memoText: String, targetDate: Date, memoId: String) async throws {
        let calendar = Calendar.current
        let timeZone = TimeZone.current

        // 既存の通知を削除
        removeReminderNotifications(for: memoId)

        // 1. 3日前の通知
        if let threeDaysBefore = calendar.date(byAdding: .day, value: -3, to: targetDate),
           threeDaysBefore > Date() {
            let morningComponents = calendar.dateComponents(in: timeZone, from: threeDaysBefore)
            var threeDaysComponents = DateComponents()
            threeDaysComponents.year = morningComponents.year
            threeDaysComponents.month = morningComponents.month
            threeDaysComponents.day = morningComponents.day
            threeDaysComponents.hour = 9 // 朝9時
            threeDaysComponents.minute = 0

            let content = UNMutableNotificationContent()
            content.title = "リマインド"
            content.body = "\(memoText) - 3日後です"
            content.sound = UNNotificationSound.default

            let trigger = UNCalendarNotificationTrigger(dateMatching: threeDaysComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "\(memoId)_3days", content: content, trigger: trigger)

            try await UNUserNotificationCenter.current().add(request)
        }

        // 2. 当日の通知（設定時刻）
        let todayComponents = calendar.dateComponents(in: timeZone, from: targetDate)
        let todayContent = UNMutableNotificationContent()
        todayContent.title = "今日です！忘れてませんか？"
        todayContent.body = memoText
        todayContent.sound = UNNotificationSound.default

        let todayTrigger = UNCalendarNotificationTrigger(dateMatching: todayComponents, repeats: false)
        let todayRequest = UNNotificationRequest(identifier: "\(memoId)_today", content: todayContent, trigger: todayTrigger)

        try await UNUserNotificationCenter.current().add(todayRequest)

        // 3. 翌日の通知
        if let nextDay = calendar.date(byAdding: .day, value: 1, to: targetDate) {
            let nextDayComponents = calendar.dateComponents(in: timeZone, from: nextDay)
            var tomorrowComponents = DateComponents()
            tomorrowComponents.year = nextDayComponents.year
            tomorrowComponents.month = nextDayComponents.month
            tomorrowComponents.day = nextDayComponents.day
            tomorrowComponents.hour = 10 // 朝10時
            tomorrowComponents.minute = 0

            let tomorrowContent = UNMutableNotificationContent()
            tomorrowContent.title = "忘れてませんか？"
            tomorrowContent.body = "昨日のやつ: \(memoText)"
            tomorrowContent.sound = UNNotificationSound.default

            let tomorrowTrigger = UNCalendarNotificationTrigger(dateMatching: tomorrowComponents, repeats: false)
            let tomorrowRequest = UNNotificationRequest(identifier: "\(memoId)_tomorrow", content: tomorrowContent, trigger: tomorrowTrigger)

            try await UNUserNotificationCenter.current().add(tomorrowRequest)
        }
    }

    // 特定メモのリマインド通知を削除
    public func removeReminderNotifications(for memoId: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            "\(memoId)_3days",
            "\(memoId)_today",
            "\(memoId)_tomorrow"
        ])
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
