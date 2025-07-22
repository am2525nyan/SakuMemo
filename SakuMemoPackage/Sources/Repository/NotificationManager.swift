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

    // 通知段階を定義
    public enum NotificationStage {
        case threeDaysBefore
        case today
        case nextDay
    }

    // AI生成通知メッセージを取得
    private func generateNotificationMessage(memoText: String, stage: NotificationStage) async -> (title: String, body: String) {
        do {
            let prompt = createPromptForStage(stage: stage, memoText: memoText)

            // GeminiRepositoryのインスタンスを作成
            let geminiRepository = GeminiRepository()

            // geminiTextメソッドを使用（[String]?を返す）
            if let textArray = await geminiRepository.geminiText(for: prompt),
               let firstResult = textArray.first {
                // レスポンスをパース（タイトル|ボディ形式を期待）
                let parts = firstResult.split(separator: "|").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                if parts.count >= 2 {
                    return (title: parts[0], body: parts[1])
                } else {
                    // パースに失敗した場合はレスポンス全体をボディにして、デフォルトタイトルを使用
                    return (title: getDefaultTitle(stage: stage), body: firstResult)
                }
            } else {
                // AI生成に失敗した場合
                print("AI通知メッセージ生成に失敗しました")
                return getDefaultMessage(stage: stage, memoText: memoText)
            }
        } catch {
            print("AI通知メッセージ生成エラー: \(error)")
            // フォールバック：固定メッセージを使用
            return getDefaultMessage(stage: stage, memoText: memoText)
        }
    }

    // 段階別プロンプト作成
    private func createPromptForStage(stage: NotificationStage, memoText: String) -> String {
        switch stage {
        case .threeDaysBefore:
            return """
            メモ「\(memoText)」の3日前リマインダー通知を作成して。
            Duolingoのような親しみやすく軽いトーンで、日本語で。
            準備や心構えを促すような内容で。
            「タイトル|メッセージ本文」の形式で返して。

            例: 
            「そろそろですね！|3日後に「\(memoText)」の予定ですよ〜」
            「準備はいかが？|もうすぐですね！準備だけでもしておきませんか？」
            """
        case .today:
            return """
            メモ「\(memoText)」の当日リマインダー通知を作成して。
            Duolingoのような親しみやすいけど少し緊迫感のあるトーンで、日本語で。
            今日が期限であることを伝える内容で。
            「タイトル|メッセージ本文」の形式で返して。

            例:
            「今日ですよ！|「\(memoText)」忘れてませんよね？」
            「その時がきました|今日こそ！「\(memoText)」やりましょう！」
            """
        case .nextDay:
            return """
            メモ「\(memoText)」の期限翌日リマインダー通知を作成して。
            Duolingoのような少し皮肉めいてるけど応援的なトーンで、日本語で。
            昨日が期限だったことを優しく指摘しつつ、まだ間に合うことを伝える内容で。
            「タイトル|メッセージ本文」の形式で返して。

            例:
            「あれ...？|昨日が「\(memoText)」の期限でしたけど...でも大丈夫！」
            「忘れちゃいました？|「\(memoText)」昨日の予定でしたよね。今からでも！」
            """
        }
    }

    // デフォルトタイトル取得
    private func getDefaultTitle(stage: NotificationStage) -> String {
        switch stage {
        case .threeDaysBefore:
            return "そろそろですね！"
        case .today:
            return "今日ですよ！"
        case .nextDay:
            return "忘れちゃいました？"
        }
    }

    // フォールバック用固定メッセージ
    private func getDefaultMessage(stage: NotificationStage, memoText: String) -> (title: String, body: String) {
        switch stage {
        case .threeDaysBefore:
            return (title: "そろそろですね！", body: "\(memoText) - 3日後です")
        case .today:
            return (title: "今日ですよ！", body: "\(memoText)")
        case .nextDay:
            return (title: "忘れちゃいました？", body: "昨日のやつ: \(memoText)")
        }
    }

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

            // AI生成メッセージを取得
            let aiMessage = await generateNotificationMessage(memoText: memoText, stage: .threeDaysBefore)

            let content = UNMutableNotificationContent()
            content.title = aiMessage.title
            content.body = aiMessage.body
            content.sound = UNNotificationSound.default

            let trigger = UNCalendarNotificationTrigger(dateMatching: threeDaysComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "\(memoId)_3days", content: content, trigger: trigger)

            try await UNUserNotificationCenter.current().add(request)
        }

        // 2. 当日の通知（設定時刻）
        let todayComponents = calendar.dateComponents(in: timeZone, from: targetDate)
        // AI生成メッセージを取得
        let todayAiMessage = await generateNotificationMessage(memoText: memoText, stage: .today)

        let todayContent = UNMutableNotificationContent()
        todayContent.title = todayAiMessage.title
        todayContent.body = todayAiMessage.body
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

            // AI生成メッセージを取得
            let tomorrowAiMessage = await generateNotificationMessage(memoText: memoText, stage: .nextDay)

            let tomorrowContent = UNMutableNotificationContent()
            tomorrowContent.title = tomorrowAiMessage.title
            tomorrowContent.body = tomorrowAiMessage.body
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
