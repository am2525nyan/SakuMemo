//
//  GeminiRepository.swift
//  SakuMemo
//
//  Created by saki on 2025/04/22.
//

import Alamofire
import ComposableArchitecture
import FirebaseAI
import Foundation
import RepositoryProtocol
import SharedModel

public struct GeminiRepository: GeminiRepositoryProtocol {
    let env: LoadEnv

    init() {
        do {
            self.env = try LoadEnv()
        } catch {
            print("🚨 Failed to load .env file: \(error)")
            fatalError("Environment configuration is required but could not be loaded.")
        }
    }

    public func gemini(for content: String) async -> MemoAnalysisResult? {
        let prompt = """
        「\(content)」を重要度に応じて0.0~1.0まで数字分けします。下記例を参考に判断してください：

        【緊急・重要（0.8-1.0）】
        課題やる = 1.0, 会議準備 = 0.9, りんご買う = 0.9, 薬を飲む = 0.8

        【重要だが緊急でない（0.5-0.7）】  
        appleについて調べる = 0.7, 本を読む = 0.6, ゴミを捨てる = 0.6, 運動する = 0.5

        【願望・希望（0.1-0.4）】
        メモアプリ作りたい = 0.2, appleについて調べたい = 0.3, ゴミを捨てたい = 0.4, 旅行したい = 0.2

        【低優先度（0.0-0.2）】
        寝たい = 0.1, テレビ見たい = 0.1, なんとなく散歩 = 0.1

        語尾の「たい」「したい」は願望なので低めに設定してください。
        また「\(content)」をジャンル分けもしてください。「買い物」「todo」「やりたいこと」のどれかに割り振ってください。

        以下のフォーマットに沿って、一つだけ出力してください。**前後に説明文は不要です**：

        {
          "importance": 0.9,
          "category": "買い物"
        }
        """

        let url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
        let params: Parameters = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        do {
            let data = try await AF.request(
                "\(url)?key=\(env.value("APIKEY") ?? "")",
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .serializingDecodable(GeminiResponse.self).value
            if let text = data.candidates.first?.content.parts.first?.text {
                if let result = parseAnalysisResult(from: text) {
                    return result
                }
            } else {
                print("失敗！")
            }
        } catch {
            print("🚨 エラー:", error)
        }
        return nil
    }

    struct GeminiResponse: Codable {
        let candidates: [Candidate]
        let usageMetadata: UsageMetadata
        let modelVersion: String
    }

    struct Candidate: Codable {
        let content: Content
        let finishReason: String
        let avgLogprobs: Double
    }

    struct Content: Codable {
        let parts: [Part]
        let role: String
    }

    struct Part: Codable {
        let text: String
    }

    struct UsageMetadata: Codable {
        let promptTokenCount: Int
        let candidatesTokenCount: Int
        let totalTokenCount: Int
    }

    func parseAnalysisResult(from jsonString: String) -> MemoAnalysisResult? {
        print(jsonString)
        guard let data = jsonString.data(using: .utf8)
        else {
            return nil
        }
        print(data)
        return try? JSONDecoder().decode(MemoAnalysisResult.self, from: data)
    }

    public func geminiText(for content: String) async -> [String]? {
        let prompt = """
        「\(content)」から、タスクを抽出してください。幾つになっても大丈夫です。
        例えば以下のような文章があった時にはこのように出力してください。
        例　明日友達が家に来てご飯を作るから、部屋の掃除をしてから、買い物に行く
        → 部屋の掃除機をかける、キッチンをきれいにする、買い物リストを作る、買い物に行く
        のようにタスクを抽出してください。
        そして、以下のフォーマットに沿って、一つだけ出力してください。**前後に説明文は不要です**：
        [部屋の掃除機をかける,キッチンをきれいにする,買い物リストを作る,買い物に行く]
        """

        let url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
        let params: Parameters = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        do {
            let data = try await AF.request(
                "\(url)?key=\(env.value("APIKEY") ?? "")",
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .serializingDecodable(GeminiResponse.self).value
            if let text = data.candidates.first?.content.parts.first?.text {
                print(text)
                let textArray =
                    text
                        .split(separator: ",")
                        .map { substring in
                            let cleaned = substring
                                .replacingOccurrences(of: "[", with: "")
                                .replacingOccurrences(of: "]", with: "")
                            return String(cleaned).trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                return textArray
            }
        } catch {
            print("🚨 エラー:", error)
        }
        return nil
    }

    public func generateNotificationMessage(memoText: String, stage: String) async -> NotificationMessage? {
        let prompt = """
        メモ「\(memoText)」の\(stage)リマインダー通知を作成してください。
        Duolingoのような親しみやすいトーンで、日本語で作成してください。

        以下のフォーマットに沿って、JSONで出力してください。**前後に説明文は不要です**：
        {
          "title": "通知のタイトル",
          "body": "通知のメッセージ本文"
        }
        """

        let url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

        // Sendableプロトコルに準拠するため、複雑なパラメータはプリミティブ型で構築
        let params: Parameters = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        do {
            let data = try await AF.request(
                "\(url)?key=\(env.value("APIKEY") ?? "")",
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .serializingDecodable(GeminiResponse.self).value

            if let text = data.candidates.first?.content.parts.first?.text {
                return parseNotificationMessage(from: text)
            }
        } catch {
            print("🚨 通知メッセージ生成エラー:", error)
        }
        return nil
    }

    func parseNotificationMessage(from jsonString: String) -> NotificationMessage? {
        print("通知メッセージJSON: \(jsonString)")
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(NotificationMessage.self, from: data)
    }
}

public struct GeminiRepositoryKey: DependencyKey {
    public static let liveValue: GeminiRepositoryProtocol = GeminiRepository()
}

public extension DependencyValues {
    var geminiRepository: GeminiRepositoryProtocol {
        get { self[GeminiRepositoryKey.self] }
        set { self[GeminiRepositoryKey.self] = newValue }
    }
}
