//
//  TaskView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import SwiftUI
import ComposableArchitecture

struct MemoView: View {
    @Bindable var store :StoreOf<MemoReducer>
    @State private var text: String = ""
    @State private var memos: [Memo] = []
    var body: some View {
        VStack {
        
            HStack{
                TextField("メモを入力", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                  
                Button(action: {
                    print("送信")
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
            .init(initialState: MemoReducer.State(),
                  reducer: {
        MemoReducer()
    }))
}
