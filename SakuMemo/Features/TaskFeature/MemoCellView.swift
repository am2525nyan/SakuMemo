//
//  MemoCellView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/19.
//

import SwiftUI

struct MemoCellView: View {
    @State var memo: Memo
    var body: some View {
        HStack {
            Text(memo.priority.emoji)
                
            Text(memo.text)
            Spacer()
            Text(memo.category.rawValue)
                .foregroundColor(.gray)
                
        }
        .padding(.horizontal, 20)
        .opacity(memo.priority.opacity(for: memo.priority))
    }
}

#Preview {
    MemoCellView(memo: Memo(text: "買い物", category: .shopping, priority: .hot))
}
