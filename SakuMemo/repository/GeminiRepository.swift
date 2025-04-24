//
//  geminiRepository.swift
//  SakuMemo
//
//  Created by saki on 2025/04/22.
//

import Foundation
import Alamofire
import ComposableArchitecture

struct GeminiRepository: GeminiRepositoryProtocol {
    let env = try! LoadEnv()
    func gemini(for content: String) async -> MemoAnalysisResult? {
        let prompt = """
        「\(content)」を重要度に応じて0.0~1.0まで数字分けするとします。重要なものやすぐにやること、必要なものは1.0に近く、すぐに必要ではない、〇〇したいのような願望や重要度が薄いものは0.0に近づけてください。
        例　りんご =0.9, メモアプリ作りたい = 0.2 ,課題やる = 1.0, appleについて調べる = 0.5
        また「\(content)」をジャンル分けもしてください。「買い物」「todo」「やりたいこと」のどれかに割り振ってください。
        
        そして、以下のフォーマットに沿って、出力してください。**前後に説明文は不要です**：
        
        {
          "importance": 0.9,
          "category": "買い物"
        }
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
            if let text = data.candidates.first?.content.parts.first?.text{
                print(text)
                if  let result = parseAnalysisResult(from: text) {
                    
                    print(result)
                    return result
                }else{
                    print("parse失敗")
                }
            }
            else{
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
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(MemoAnalysisResult.self, from: data)
    }
    
}

struct GeminiRepositoryKey: DependencyKey {
    static var liveValue: GeminiRepositoryProtocol = GeminiRepository()
    
}

extension DependencyValues {
    var geminiRepository: GeminiRepositoryProtocol {
        get { self[GeminiRepositoryKey.self] }
        set { self[GeminiRepositoryKey.self] = newValue }
    }
}

struct MemoAnalysisResult: Decodable {
    let importance: Double
    let category: String
}
