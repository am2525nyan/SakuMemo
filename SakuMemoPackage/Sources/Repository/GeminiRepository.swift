//
//  geminiRepository.swift
//  SakuMemo
//
//  Created by saki on 2025/04/22.
//

import Foundation
import Alamofire
import ComposableArchitecture
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
        「\(content)」を重要度に応じて0.0~1.0まで数字分けするとします。下記例を参考に、重要なものやすぐにやること、必要なものは1.0に近く、すぐに必要ではない、〇〇したいのような願望や希望、重要度、緊急度、すぐじゃなくてもいいものは0.0に近づけてください。語尾などにも注目してください
        例　りんご =0.9, メモアプリ作りたい = 0.2 ,課題やる = 1.0, appleについて調べる = 0.8,  appleについて調べたい = 0.5, ゴミを捨てたい = 0.4, ゴミを捨てる = 0.8, 寝たい = 0.1
        また「\(content)」をジャンル分けもしてください。「買い物」「todo」「やりたいこと」のどれかに割り振ってください。
        
        そして、以下のフォーマットに沿って、一つだけ出力してください。**前後に説明文は不要です**：
        
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
                if  let result = parseAnalysisResult(from: text) {
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
        print(jsonString)
        guard let data = jsonString.data(using: .utf8) else { return nil }
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
                let textArray = text
                    .split(separator: ",")
                    .map { substring in
                        let cleaned = substring
                            .replacingOccurrences(of: "[", with: "")
                            .replacingOccurrences(of: "]", with: "")
                        return String(cleaned).trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                return textArray
            }
            else{
                print("失敗！")
            }
            
        } catch {
            print("🚨 エラー:", error)
            
        }
        return nil
        
    }
    
    
    
}

public struct GeminiRepositoryKey:DependencyKey {
    public static let liveValue: GeminiRepositoryProtocol = GeminiRepository()
    
}

public extension DependencyValues {
    var geminiRepository: GeminiRepositoryProtocol {
        get { self[GeminiRepositoryKey.self] }
        set { self[GeminiRepositoryKey.self] = newValue }
    }
}

