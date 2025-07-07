//  FoundationModels.swift
//  SakuMemoPackage
//
//  Created by saki on 2025/06/30.
//

import Foundation
import FoundationModels
import ComposableArchitecture
import SharedModel



public struct FoundationModelRepository : Sendable{
    public init() {}
    @available(iOS 26.0, *)
    public func respond(userInput: String) async throws -> MemoAnalysisResult {
        let prompt = """
「ユーザーから与えられた 「\(userInput)」を重要度に応じて0.0~1.0まで数字分けするとします。下記例を参考に、重要なものやすぐにやること、必要なものは1.0に近く、すぐに必要ではない、〇〇したいのような願望や希望、重要度、緊急度、すぐじゃなくてもいいものは0.0に近づけてください。語尾などにも注目してください
例　りんご =0.9, メモアプリ作りたい = 0.2 ,課題やる = 1.0, appleについて調べる = 0.8,  appleについて調べたい = 0.5, ゴミを捨てたい = 0.4, ゴミを捨てる = 0.8, 寝たい = 0.1
"""
        let session = LanguageModelSession(instructions: prompt)
        let response = try await session.respond(to: userInput,generating:MemoResponse.self)
        print("Response: \(response)")
        return MemoAnalysisResult(importance: response.content.importance, category: response.content.category)
    }
}

@available(iOS 26.0, *)
@Generable
struct MemoResponse {
    @Guide(.range(0.0...1.0))
    public let importance: Double
    @Guide(.anyOf(["買い物", "todo", "やりたいこと"]))
    public let category: String
    
    
}
public struct FoundationModelsRepositoryKey:DependencyKey {
   
    public static let liveValue = FoundationModelRepository()
    
}

public extension DependencyValues {
 
    var foundationModelsRepository: FoundationModelRepository {
        get { self[FoundationModelsRepositoryKey.self] }
        set { self[FoundationModelsRepositoryKey.self] = newValue }
    }
}
//@available(iOS 26.0, *)
//#Playground("FoundationModels") {
//    let userInput = "ネイルデザイン決めたい"
//    let prompt = """
//「ユーザーから与えられた 「\(userInput)」を重要度に応じて0.0~1.0まで数字分けするとします。下記例を参考に、重要なものやすぐにやること、必要なものは1.0に近く、すぐに必要ではない、〇〇したいのような願望や希望、重要度、緊急度、すぐじゃなくてもいいものは0.0に近づけてください。語尾などにも注目してください
//例　りんご =0.9, メモアプリ作りたい = 0.2 ,課題やる = 1.0, appleについて調べる = 0.8,  appleについて調べたい = 0.5, ゴミを捨てたい = 0.4, ゴミを捨てる = 0.8, 寝たい = 0.1
//"""
//    let session = LanguageModelSession(instructions: prompt)
//    let response = try await session.respond(to: userInput,generating:MemoResponse.self)
//    print("Response: \(response)")
//  
//}
