//
//  ListComponent.swift
//  SakuMemo
//
//  Created by saki on 2025/05/16.
//

import SwiftUI
import SharedModel

public struct ListComponent: View {
    public init( memos: Binding<[Memo]>, tapAction: @escaping (Memo) -> Void, swipeTrailingAction: @escaping (Memo) -> Void, swipeLeadingAction: @escaping (Memo) -> Void, trailingText: String, leadingText: String) {
        
        self._memos = memos
        self.tapAction = tapAction
        self.swipeTrailingAction = swipeTrailingAction
        self.swipeLeadingAction = swipeLeadingAction
        self.trailingText = trailingText
        self.leadingText = leadingText
    }
    @Binding var memos: [Memo]
    public let tapAction: (Memo) -> Void
    public let swipeTrailingAction: (Memo) -> Void
    public let swipeLeadingAction: (Memo) -> Void
    public var trailingText: String
    public var leadingText: String
    public  var body: some View {
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
        memos: .constant([Memo(text: "")]),
        tapAction: {_ in
            print("")
        }, swipeTrailingAction:{ _ in
            print("")
        }, swipeLeadingAction: {_ in
            print("")
        }, trailingText: "アーカイブ",
        leadingText: "削除")
}
