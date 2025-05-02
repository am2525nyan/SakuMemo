//
//  MemoDetailFeature.swift
//  SakuMemo
//
//  Created by saki on 2025/04/30.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MemoDetailFeature{
    
    @ObservableState
    struct State {
        var memo:Memo
        var priorityValue = 0.0
    }
    enum Action :BindableAction{
        case binding(BindingAction<State>)
        case onAppear
        case setNotification
        case removeNotification
    }
    
    @Dependency(\.notificationManager) var notificationManager
    var body: some ReducerOf<Self>{
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
                        await notificationManager.sendNotification(title: "忘れてませんか？", body: text, date: date, id: id)
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
