//
//  MemoDetailView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/30.
//

import SwiftUI
import ComposableArchitecture


struct MemoDetailView: View {
    @Bindable var store: StoreOf<MemoDetailFeature>
    @FocusState var isFocused :Bool
    var body: some View {
        VStack{
            HStack{
                Text("内容：")
                TextField("メモ", text: $store.memo.text)
                    .textFieldStyle(.customTextField(isFocused: _isFocused))
                    .focused($isFocused)
            }
            HStack{
                Text("重要度：")
                Slider(value: $store.memo.priorityValue,
                       in: 0...1,
                       step: 0.1)
            }
            HStack{
                Text("カテゴリー：")
                Menu{
                    Button("todo"){
                        store.memo.category = "todo"
                    }
                    Button("やりたいこと"){
                        store.memo.category = "やりたいこと"
                    }
                    Button("買い物"){
                        store.memo.category = "買い物"
                    }
                    Button("未分類"){
                        store.memo.category = "未分類"
                    }
                    
                }
                label: {
                    Text(store.memo.category)
                    
                }
                Spacer()
            }
            
            if store.memo.date != nil{
                HStack{
                    DatePicker("日付：",
                               selection: Binding<Date>(get:{ self.store.memo.date ?? Date()},set: {self.store.memo.date = $0}),
                               displayedComponents: [.date, .hourAndMinute]
                    )
                    Button(role: .destructive, action: {
                        store.memo.date = nil
                        
                    }, label: {
                        Text("×")
                            .font(.system(size: 25))
                        
                    })
                    
                    
                }
            }else{
                Button(action: {
                    store.memo.date = Date()
                   
                }, label: {
                    Text("日付を追加")
                })
                .buttonStyle(.customButton)
            }
            
        }
        
        .padding(.horizontal,20)
        .onAppear(){
            store.send(.onAppear)
        }
        .onChange(of: store.memo.date){
            store.send(.setNotification)
        } 
    }
}

#Preview {
    MemoDetailView( store: .init(initialState: MemoDetailFeature.State(memo:Memo(text: "お掃除する")), reducer: {
        MemoDetailFeature()
    }))
}
