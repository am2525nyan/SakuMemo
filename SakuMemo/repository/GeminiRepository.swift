//
//  geminiRepository.swift
//  SakuMemo
//
//  Created by saki on 2025/04/22.
//

import Foundation
import Alamofire

    struct GeminiRepository {
        let content: String
        let env = try! LoadEnv()
        func gemini() async -> String {
            let prompt = """
               「\(content)」を重要度に応じて0.0~1.0まで数字分けするとします。重要なものやすぐにやること、必要なものは1.0に近く、すぐに必要ではない、したいかものような願望や薄いものは0.0に近づけてください。そして数字だけを出力してください。(前後の説明は不要です)
            """

            let url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
            let params: Parameters = [
                "contents":[
                    [
                        "parts": [
                            ["text": prompt]
                        ]
                    ]
                ]
            ]
            let headers: HTTPHeaders = [
                "Content-Type":"application/json",
            ]

            do {
                let data = try await AF.request("\(url)?key=\(env.value("APIKEY") ?? "")",
                                                method: .post,
                                                parameters: params,
                                                encoding: JSONEncoding.default,
                                                headers: headers)
                    .serializingDecodable(GeminiResponse.self).value

                if let text = data.candidates.first?.content.parts.first?.text {
                    return text
                }

            } catch {
                print("🚨 エラー:", error)
            }

            return ""
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

    }

