//
//  MemoCellView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/19.
//

import SharedModel
import SwiftUI

public struct MemoCellView: View {
    @State var memo: Memo

    public init(memo: Memo) {
        self.memo = memo
    }

    public var body: some View {
        HStack {
            Menu {
                Button("🔥") {
                    memo.priorityValue = 1
                }
                Button("⛅️") {
                    memo.priorityValue = 0.5
                }

                Button("🧊") {
                    memo.priorityValue = 0
                }
            }
            label: {
                Text(memo.priority.emoji)
            }

            Text(memo.text)
            Spacer()
            Menu {
                Button("todo") {
                    memo.category = "todo"
                }
                Button("買い物") {
                    memo.category = "買い物"
                }

                Button("やりたいこと") {
                    memo.category = "やりたいこと"
                }
            }
            label: {
                Text(memo.category)
                    .foregroundColor(.gray)
            }
        }

        .padding(.horizontal, 20)
        .opacity(memo.priority.opacity(for: memo.priority))
    }
}

#Preview {
    MemoCellView(memo: Memo(text: "買い物", category: "買い物", priorityValue: 1))
}
