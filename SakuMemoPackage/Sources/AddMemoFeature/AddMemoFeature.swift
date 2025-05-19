//
//  AddMemoFeature.swift
//  SakuMemo
//
//  Created by saki on 2025/05/03.
//

import Foundation
import ComposableArchitecture
import SharedModel
import Repository

@Reducer
public struct AddMemoFeature: Sendable{
    public init() {}
    @ObservableState
    public struct State {
        public init() {}
        var text: String = ""
        var isSending: Bool = false
        var isTextField: Bool = true
        var memoList: [String] = []
        var memo = Memo(text: "")
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case save
        case geminiSuccess([String])
        case geminiFailure
        case showTextField
        case addMemo(String)
        case gemini
        case geminiError
        case geminiSuccessText(MemoAnalysisResult)
    }
    @Dependency(\.geminiRepository) var geminiRepository
    @Dependency(\.swiftDataRepository) var swiftDataRepository
    public var body: some ReducerOf<Self> {
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
                state.isTextField = false
                state.memoList = result
                
                return .none
            case .geminiFailure:
                state.isSending = false
                state.isTextField = false
                
                return .none
            case .showTextField:
                state.isTextField = true
                return .none
            case .addMemo(let text):
                let memo = Memo(text: text)
                state.memo = memo
                state.memoList.removeAll(where:{
                    (value) in
                    value == text
                })
                return .run { send in
                    
                    do{
                        await send(.gemini)
                        
                    }
                    
                    
                }
            case .gemini:
                let text = state.memo.text
                return .run { send in
                    if let result = await geminiRepository.gemini(for: text) {
                        await send(.geminiSuccessText(result))
                    } else {
                        print("⚠️ Geminiの解析に失敗")
                        await send(.geminiError)
                    }
                }
                
            case .geminiSuccessText(let result):
                state.memo.priorityValue = result.importance
                state.memo.category = result.category
                let memo = state.memo
                let newMemo = MemoSendable(
                    id: memo.id, text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { send in
                    
                    try await swiftDataRepository.addMemo(newMemo: newMemo)
                }
                
            case .geminiError:
                let memo = state.memo
                state.text = ""
                let delete = MemoSendable(
                    id: memo.id, text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { send in
                    
                    try await swiftDataRepository.addMemo(newMemo: delete)
                }
            }
        }
    }
}
