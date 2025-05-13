//
//  AddMemoView.swift
//  SakuMemo
//
//  Created by saki on 2025/05/03.
//

import SwiftUI
import ComposableArchitecture

struct AddMemoView: View {
    @Bindable var store: StoreOf<AddMemoFeature>
    @FocusState private var isFocused: Bool
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Button{
                    store.send(.showTextField)
                    
                }label: {
                    Image(systemName: "text.justifyright")
                }
                .padding(.leading, 20)
                .disabled(store.memoList.isEmpty)
                
                Button{
                    store.send(.save)
                }label: {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(store.text.isEmpty && !store.isSending || !store.isTextField)
                .padding(.leading, 20)
                
            }
            .padding(.bottom,20)
            if store.isTextField{
                TextField("メモを入力",text: $store.text,axis: .vertical)
                    .textFieldStyle(.customTextField(isFocused: _isFocused))
                
                    .lineLimit(5...300)
                    .focused($isFocused)
                    .padding(.top, 20)
            }
            
            if !store.isTextField || !store.memoList.isEmpty{
                List{
                    
                    ForEach(store.memoList, id: \.self) { memo in
                        HStack{
                            Text(memo)
                            Spacer()
                            Button{
                                store.send(.addMemo(memo))
                                
                            }label: {
                                Image(systemName: "plus")
                                    .foregroundStyle(.cyan)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .swipeActions(content: {
                            Button(role: .destructive) {
                                
                                store.send(.addMemo(memo))
                                
                            }label: {
                                Image(systemName: "plus")
                                    .foregroundStyle(.cyan)
                            }
                            .tint(.cyan)
                            
                        })
                        .padding(.horizontal, 20)
                        
                        
                    }
                    
                }
                .listStyle(.plain)
                
            }
            
        }
        .padding(.top,20)
        .padding(.horizontal, 20)
    }
}

#Preview {
    AddMemoView(store: .init(initialState: AddMemoFeature.State(
        memoList: [
            "シュー生地を作る",
            "カスタードクリームを作る",
            "生クリームを泡立てる",
            "シュー生地を焼く",
            "カスタードクリームを冷ます",
            "シュー生地にクリームを詰める",
            "粉砂糖をかける",
            "冷蔵庫で冷やす"
        ]
    ), reducer: {
        AddMemoFeature()
    }))
}
