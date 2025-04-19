//
//  TaskView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import SwiftUI

struct MemoView: View {
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
            .padding(.bottom, 20)
            
            List {
                ForEach(memos) { memo in
                    MemoCellView(memo: memo)
                }
            }
            .listStyle(PlainListStyle())
        }
        .onAppear(){
          memos = [
            Memo(text: "バナナ", category: .shopping,priority: .hot),
            Memo(text: "Reducer書く", category: .todo, priority: .warm),
            Memo(text: "旅行準備したい", category: .note, priority: .cold),
            Memo(text: "りんご", category: .shopping,priority: .hot),
            Memo(text: "インターンのDM返す！", category: .todo, priority: .hot),
            Memo(text: "visionPro欲しい", category: .note, priority: .cold),
            ]
        }
       
    }
}

#Preview {
    MemoView()
}
