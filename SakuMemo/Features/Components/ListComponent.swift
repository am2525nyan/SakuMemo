//
//  ListComponent.swift
//  SakuMemo
//
//  Created by saki on 2025/05/16.
//

import SwiftUI

struct ListComponent: View {
    @Binding var memos: [Memo]
    let tapAction: (Memo) -> Void
    let swipeTrailingAction: (Memo) -> Void
    let swipeLeadingAction: (Memo) -> Void
    var trailingText: String
    var leadingText: String
    var body: some View {
        List {
            ForEach(memos) { memo in
                HStack{
                    MemoCellView(memo: memo)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    tapAction(memo)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        swipeTrailingAction(memo)
                    } label: {
                        Text(trailingText)
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        swipeLeadingAction(memo)
                        
                    } label: {
                        Text(leadingText)
                    }
                    .tint(.cyan)
                }
            }
            
        }
        .listStyle(PlainListStyle())
    }
}

#Preview {
    ListComponent(
        memos: .constant([Memo(text: "りんご")]),
        tapAction: {_ in
            print("")
        }, swipeTrailingAction:{ _ in
            print("")
        }, swipeLeadingAction: {_ in
            print("")
        }, trailingText: "アーカイブ",
        leadingText: "削除")
}
