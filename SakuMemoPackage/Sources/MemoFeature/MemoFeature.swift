//
//  TaskReducer.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import Foundation
import ComposableArchitecture
import SharedModel
import AddMemoFeature
import MemoDetailFeature

@Reducer
public struct MemoFeature : Sendable{
    public init() {}
    
    @ObservableState
    public struct State{
        public init() {}
        var memo = Memo(text: "")
        var text: String = ""
        
        @Presents var detail: MemoDetailFeature.State?
        @Presents var add: AddMemoFeature.State?
        var isShowDetails: Bool = false
        var isShowAdd: Bool = false
        var isShowPopup: Bool = false
    }
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case addMemo
        case gemini
        case success(MemoAnalysisResult)
        case error
        case deleteMemo(Memo)
        case deleteAllMemos
        case archive(Memo)
        case onAppear
        case presentMemoDetail(PresentationAction<MemoDetailFeature.Action>)
        case presentAddMemo(PresentationAction<AddMemoFeature.Action>)
        case showDetail(Memo)
        case showAddMemo
        case showPopup
        case closePopup
        case foundationModels
        case switchAi
        
        
    }
    @Dependency(\.swiftDataRepository) var swiftDataRepository
    @Dependency(\.geminiRepository) var geminiRepository
    @Dependency(\.notificationManager) var notificationManager
    @Dependency(\.continuousClock) var clock
    @Dependency(\.foundationModelsRepository) var foundationModelsRepository
    
    public var body: some ReducerOf <Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .addMemo:
                let memo = Memo(text: state.text)
                state.memo = memo
                state.text = ""
                return .run { send in
                    
                    do{
                        await send(.switchAi)
                        
                    }
                    
                    
                }
            case .gemini:
                let text = state.memo.text
                return .run { send in
                    if let result = await geminiRepository.gemini(for: text) {
                        await send(.success(result))
                    } else {
                        print("⚠️ Geminiの解析に失敗")
                        await send(.error)
                    }
                }
            case .foundationModels:
                let text = state.memo.text
                return .run { send in
                    if #available(iOS 26.0, *) {
                        do{
                            let result = try await foundationModelsRepository.respond(userInput: text)
                            await send(.success(result))
                        }catch{
                            print("⚠️Foundation Modelsの解析に失敗: \(error)")
                            await send(.error)
                        }
                        
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                
            case .success(let result):
                state.memo.priorityValue = result.importance
                state.memo.category = result.category
                let memo = state.memo
                let new = MemoSendable(
                    id: memo.id, text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { send in
                    try await swiftDataRepository.addMemo(newMemo: new)
                    await send(.showPopup)
                }
                
            case .deleteAllMemos:
                return .run { send in
                    try await swiftDataRepository.deleteAllMemos()
                }
                
            case .binding(_):
                return .none
            case .error:
                let memo = state.memo
                state.text = ""
                let new = MemoSendable(
                    id: memo.id, text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { send in
                    try await swiftDataRepository.addMemo(newMemo: new)
                }
            case .deleteMemo(let memo):
                let new = MemoSendable(
                    id: memo.id, text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
                return .run { send in
                    try await swiftDataRepository.deleteMemo(memo: new)
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
            case .showPopup:
                state.isShowPopup = true
                return .run { send in
                    try await self.clock.sleep(for: .seconds(2))
                        await send(.closePopup)
                    }
                   
                case .closePopup:
                    state.isShowPopup = false
                    return .none
              
            case .switchAi:
         if #available(iOS 26.0, *) {
             return .run { send in
                 await send(.foundationModels)
             }
                } else {
                    return .run { send in
                        await send(.gemini)
                    }
                }
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
