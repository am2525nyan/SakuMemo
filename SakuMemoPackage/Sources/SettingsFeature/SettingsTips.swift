//
//  SettingsTips.swift
//  SakuMemo
//
//  Created by Claude on 2025/09/10.
//

import TipKit

struct AutoArchiveTip: Tip {
    var title: Text {
        Text("自動アーカイブについて")
    }

    var message: Text? {
        Text("重要度が0以下になったメモは、設定した日数が経過すると自動的にアーカイブされます。")
    }

    var image: Image? {
        Image(systemName: "archivebox")
    }
}

struct PriorityDecreaseTip: Tip {
    var title: Text {
        Text("重要度減少について")
    }

    var message: Text? {
        Text("メモ作成から指定した日数が経過すると、1日ごとに重要度が0.2ずつ自動的に減少します。")
    }

    var image: Image? {
        Image(systemName: "calendar")
    }
}

struct SettingsOverviewTip: Tip {
    var title: Text {
        Text("メモの自動管理")
    }

    var message: Text? {
        Text("メモは時間が経過すると自動で重要度が下がり、最終的にアーカイブされます。ここでタイミングを調整できます。")
    }

    var image: Image? {
        Image(systemName: "lightbulb")
    }
}
