//
//  MemoDetailFeature.swift
//  SakuMemo
//
//  Created by saki on 2025/04/30.
//

import Foundation
import ComposableArchitecture
import SharedModel
import Repository

@Reducer
public struct MemoDetailFeature: Sendable{
    
    public init(){}
    @ObservableState
    public struct State {
        public init(memo: Memo, priorityValue: Double = 0.0) {
            self.memo = memo
            self.priorityValue = priorityValue
        }
        public var memo: Memo
        public var priorityValue = 0.0
    }
    public enum Action :BindableAction{
        case binding(BindingAction<State>)
        case onAppear
        case setNotification
        case removeNotification
    }
    
    @Dependency(\.notificationManager) var notificationManager
    public var body: some ReducerOf<Self>{
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.priorityValue = state.memo.priorityValue
                return .none
            case .binding:
                return .none
            case .setNotification:
                let date = state.memo.date
                if let date =  date{
                    print("通知を設定しました！")
                    let text = state.memo.text
                    let id = state.memo.id.uuidString
                    return .run { send in
                        try await notificationManager.sendNotification(title: "忘れてませんか？", body: text, date: date, id: id)
                    }
                    
                }
                return .none
                
            case .removeNotification:
                let id = state.memo.id.uuidString
                notificationManager.removeNotification(id: id)
                return .none
            }
            
        }
    }
}
