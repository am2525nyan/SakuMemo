////
////  playground.swift
////  SakuMemo
////
////  Created by saki on 2025/07/28.
////
// #if DEBUG
//    import Foundation
//    import FoundationModels
//    import Playgrounds
//    import Repository
//
//    @available(iOS 26.0, *)
//    @Generable
//    struct PlaygroundMemoResponse {
//        @Guide(description: "タスクの重要度", .range(0.0...1.0))
//        let importance: Double
//        @Guide(.anyOf(["買い物", "todo", "やりたいこと"]))
//        let category: String
//    }
//
//    @available(iOS 26.0, *)
//    #Playground("FoundationModels") {
//        let userInput = "掃除機かける"
//        let prompt = """
//        「\(userInput)」を重要度に応じて0.0~1.0まで数字分けします。下記例を参考に判断してください：
//
//        【緊急・重要・すぐにやること（0.8-1.0）】
//        課題やる = 1.0, 会議準備 = 0.9, りんご買う = 0.9, 薬を飲む = 0.8, ゴミを捨てる = 0.8, 掃除機をかける = 0.8
//
//        【重要だが緊急でない（0.5-0.7）】
//        appleについて調べる = 0.7, 本を読む = 0.6,  運動する = 0.5
//
//        【願望・希望（0.1-0.4）】
//        メモアプリ作りたい = 0.2, appleについて調べたい = 0.3, ゴミを捨てたい = 0.4, 旅行したい = 0.2
//
//        【低優先度（0.0-0.2）】
//        寝たい = 0.1, テレビ見たい = 0.1, なんとなく散歩 = 0.1
//
//        語尾の「たい」「したい」は願望なので低めに設定してください。
//        """
//        let session = LanguageModelSession(instructions: prompt)
//        let response = try await session.respond(to: userInput, generating: PlaygroundMemoResponse.self)
//    }
// #endif
