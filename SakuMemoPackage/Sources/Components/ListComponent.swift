//
//  ListComponent.swift
//  SakuMemo
//
//  Created by saki on 2025/05/16.
//

import SharedModel
import SwiftUI

public struct ListComponent: View {
    public init(memos: Binding<[Memo]>, tapAction: @escaping (Memo) -> Void, swipeTrailingAction: @escaping (Memo) -> Void, swipeLeadingAction: @escaping (Memo) -> Void, trailingText: String, leadingText: String, dueSoonMemos: [Memo]? = nil, showDetailMemo: ((Memo) -> Void)? = nil) {
        self._memos = memos
        self.tapAction = tapAction
        self.swipeTrailingAction = swipeTrailingAction
        self.swipeLeadingAction = swipeLeadingAction
        self.trailingText = trailingText
        self.leadingText = leadingText
        self.dueSoonMemos = dueSoonMemos
        self.showDetailMemo = showDetailMemo
    }

    @Binding var memos: [Memo]
    public let tapAction: (Memo) -> Void
    public let swipeTrailingAction: (Memo) -> Void
    public let swipeLeadingAction: (Memo) -> Void
    public var trailingText: String
    public var leadingText: String
    public var dueSoonMemos: [Memo]?
    public var showDetailMemo: ((Memo) -> Void)?

    public var body: some View {
        List {
            // 期限切れ間近のメモセクション
            if dueSoonMemos != nil {
                DueSoonSection(memos: dueSoonMemos!) { memo in
                    showDetailMemo?(memo)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }

            ForEach(memos) { memo in
                HStack {
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
                    .tint(Color.mainColor)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

#Preview {
    ListComponent(
        memos: .constant([Memo(text: "")]),
        tapAction: { _ in
            print("")
        },
        swipeTrailingAction: { _ in
            print("")
        },
        swipeLeadingAction: { _ in
            print("")
        },
        trailingText: "アーカイブ",
        leadingText: "削除"
    )
}

struct DueSoonMemoRow: View {
    let memo: Memo
    let onTap: (Memo) -> Void

    private var daysText: String {
        let daysUntilDue = memo.daysUntilDue ?? 0

        if daysUntilDue == 0 {
            return "今日"
        } else if daysUntilDue == 1 {
            return "明日"
        } else if daysUntilDue == 2 {
            return "あさって"
        } else {
            return "\(daysUntilDue)日後"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(memo.text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 12))
                    Text(daysText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap(memo)
        }
    }
}

struct DueSoonSection: View {
    let memos: [Memo]
    let onTap: (Memo) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 16))
                Text("期限が近いメモ")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                Spacer()
            }
            .padding(.vertical, 4)

            LazyVStack(spacing: 6) {
                ForEach(memos) { memo in
                    DueSoonMemoRow(memo: memo, onTap: onTap)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.vertical, 4)
        }
    }
}
