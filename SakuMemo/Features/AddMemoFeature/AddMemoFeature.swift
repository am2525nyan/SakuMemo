//
//  AddMemoFeature.swift
//  SakuMemo
//
//  Created by saki on 2025/05/03.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AddMemoFeature {
    @ObservableState
    struct State {
        var text: String = ""
        var isSending: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case save
        case geminiSuccess([String])
        case geminiFailure
    }
    @Dependency(\.geminiRepository) var geminiRepository
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .save:
                state.isSending = true
                let text = state.text
                return .run { send in
                    if let answer = await geminiRepository.geminiText(for: text){
                        await send(.geminiSuccess(answer))
                    }else{
                        await send(.geminiFailure)
                    }
                }
            case .binding(_):
                return .none
            case .geminiSuccess(let result):
                state.isSending = false
                print("Gemini Success: \(result)")
                return .none
            case .geminiFailure:
                state.isSending = false
                print("Gemini Failure")
                return .none
            }
        }
    }
}
