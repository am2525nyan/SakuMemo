//
//  TaskView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

struct MemoView: View {
    @Bindable var store: StoreOf<MemoFeature>
    var body: some View {
        VStack {
            HStack{
                TextField("メモを入力", text: $store.text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    store.send(.addMemo)
                }, label:
                        {
                    Image(systemName: "paperplane.fill")
                })
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
            List {
                ForEach(store.memos) { memo in
                    MemoCellView(memo: memo)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.send(.deleteMemo(memo))
                            } label: {
                                Text("削除")
                            }
                        }
                }
            }
            
            .listStyle(PlainListStyle())
        }
        .onAppear(){
            store.send(.refresh)
        }
        
    }
}

#Preview {
    MemoView(store:
            .init(initialState: MemoFeature.State(),
                  reducer: {
        MemoFeature()
    }))
}
