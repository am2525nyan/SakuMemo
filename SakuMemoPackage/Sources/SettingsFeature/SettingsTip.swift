//
//  SettingsTip.swift
//  SakuMemo
//
//  Created by Claude on 2025/09/10.
//

import TipKit

struct SettingsHelpTip: Tip {
    var title: Text {
        Text("メモの自動管理について")
    }

    var message: Text? {
        Text("メモは時間が経過すると自動で重要度が下がり、最終的にアーカイブされます。設定でタイミングを調整できます。")
    }

    var image: Image? {
        Image(systemName: "lightbulb")
    }
}
