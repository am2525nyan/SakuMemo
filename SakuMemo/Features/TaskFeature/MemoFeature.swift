//
//  TaskReducer.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MemoFeature {
    
    @ObservableState
    struct State{
        var memo = Memo(text: "")
        var text: String = ""
        
        @Presents var detail: MemoDetailFeature.State?
        @Presents var add: AddMemoFeature.State?
        var isShowDetails: Bool = false
        var isShowAdd: Bool = false
    }
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addMemo
        case gemini
        case geminiSuccess(MemoAnalysisResult)
        case geminiError
        case deleteMemo(Memo)
        case deleteAllMemos
        case archive(Memo)
        case onAppear
        case presentMemoDetail(PresentationAction<MemoDetailFeature.Action>)
        case presentAddMemo(PresentationAction<AddMemoFeature.Action>)
        case showDetail(Memo)
        case showAddMemo
        
    }
    @Dependency(\.swiftDataRepository) var swiftDataRepository
    @Dependency(\.geminiRepository) var geminiRepository
    @Dependency(\.notificationManager) var notificationManager
    
    var body: some ReducerOf <Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .addMemo:
                let memo = Memo(text: state.text)
                state.memo = memo
                state.text = ""
                return .run { send in
                    
                    do{
                        await send(.gemini)
                        
                    }
                    
                    
                }
            case .gemini:
                let text = state.memo.text
                return .run { send in
                    if let result = await geminiRepository.gemini(for: text) {
                        await send(.geminiSuccess(result))
                    } else {
                        print("⚠️ Geminiの解析に失敗")
                        await send(.geminiError)
                    }
                }
                
            case .geminiSuccess(let result):
                state.memo.priorityValue = result.importance
                state.memo.category = result.category
                let memo = state.memo
                
                return .run { send in
                    try await swiftDataRepository.addMemo(newMemo: memo)
                }
                
            case .deleteAllMemos:
                return .run { send in
                    try await swiftDataRepository.deleteAllMemos()
                }
                
            case .binding(_):
                return .none
            case .geminiError:
                let memo = state.memo
                state.text = ""
                return .run { send in
                    try await swiftDataRepository.addMemo(newMemo: memo)
                }
            case .deleteMemo(let memo):
                return .run { send in
                    try await swiftDataRepository.deleteMemo(memo: memo)
                }
            case .archive(let memo):
                memo.isArchived = true
                return .none
            case .onAppear:
                return .run { send in
                    do{
                        try await swiftDataRepository.archiveMemos()
                    }catch{
                        print("アーカイブ失敗")
                    }
                }
            case .presentMemoDetail:
                return .none
            case .showDetail(let memo):
                state.isShowDetails = true
                
                state.detail = MemoDetailFeature.State(memo: memo)
                
                return .none
            case .presentAddMemo:
                return .none
            case .showAddMemo:
                state.isShowAdd = true
                state.add = AddMemoFeature.State()
                return .none
            }
        }
        .ifLet(\.$detail, action: \.presentMemoDetail){
            MemoDetailFeature()
        }
        .ifLet(\.$add, action: \.presentAddMemo){
            AddMemoFeature()
        }
        
    }
}
