# SakuMemo — CLAUDE.md

AI を活用したタスク・メモ管理 iOS アプリ。メモ本文から AI がカテゴリ分類・優先度判定・タスク抽出を行い、SwiftData に保存したメモをホーム / アーカイブ / 設定タブで管理する。

## プロジェクト構成

```
SakuMemo/
├── SakuMemo/
│   └── SakuMemoApp.swift       # @main / Firebase / App Check / AdMob / 通知 / StoreKit 起動処理
├── SakuMemo.xcodeproj/         # iOS アプリ本体の Xcode プロジェクト
├── SakuMemoPackage/
│   ├── Package.swift           # Swift 6.1 / iOS 18 / macOS 15 の SPM マルチモジュール定義
│   └── Sources/
│       ├── AppFeature/         # ルートのタブ管理。Memo / Archive / Settings を Scope で合成
│       ├── MemoFeature/        # ホームタブ。メモ一覧、AI 分析、通知、詳細/追加/課金導線
│       ├── AddMemoFeature/     # メモ作成モーダル、タスク抽出、無料枠チェック
│       ├── MemoDetailFeature/  # メモ編集、期日・通知設定
│       ├── ArchiveFeature/     # アーカイブ済みメモ一覧、復元
│       ├── SettingsFeature/    # 自動アーカイブ・優先度低下などの設定
│       ├── SubscriptionFeature/# StoreKit 2 のサブスクリプション管理
│       ├── SearchFeature/      # 検索・フィルタリング関連
│       ├── AppIntent/          # Siri ショートカット
│       ├── Repository/         # SwiftData / Gemini / FoundationModels / StoreKit / 通知
│       ├── RepositoryProtocol/ # Repository の DI 用プロトコル
│       ├── SharedModel/        # Memo, UserSubscription, MemoSendable などの共有モデル
│       ├── Components/         # MemoCellView などの再利用 UI
│       └── Utils/              # Modifier / Style / UIKit bridge helpers
├── resources/                  # 補助リソース
├── .tca-reference/             # TCA 実装参考。特に Examples/SyncUps/
├── .swiftlint.yml
└── .swiftformat
```

## アーキテクチャ

- **TCA (The Composable Architecture) + SwiftUI + SwiftData** の SPM マルチモジュール構成。
- `@Reducer` + `@ObservableState` + `@Dependency` を基本形にする。
- View からの操作は原則 `ViewAction` パターン（`.view(.actionName)`）で Reducer に送る。
- バインディングは `BindableAction` + `BindingReducer()` + `@Bindable var store` を使う。
- モーダルや詳細表示は `@Presents` + `PresentationAction` + `.ifLet` で接続する。
- `AppFeature` が `MemoFeature`, `ArchiveMemoFeature`, `SettingsFeature` を `Scope` で合成する。
- `MemoFeature` はメモ一覧の中核で、追加モーダル、詳細モーダル、サブスクリプション導線、AI 分析、通知管理を統合する。
- `AddMemoFeature` はタスク抽出、無料枠チェック、AI 分析後の保存を担当する。
- TCA 実装で迷った場合は `.tca-reference/Examples/SyncUps/` を先に確認する。

## データ・AI・通知

- 永続化は SwiftData。`Memo` と `UserSubscription` を `SakuMemoApp` の `.modelContainer` に登録する。
- Feature から Repository へは `@Dependency(\.xxxRepository)` でアクセスする。
- Repository 層は `@DependencyClient` または `DependencyKey` / `DependencyValues` extension で登録する。
- SwiftData の `@Model` は Sendable 境界に直接渡さず、必要に応じて `MemoSendable` に変換する。
- AI 分析は iOS 26 / macOS 26 以降で FoundationModels を試し、利用不可・失敗時は Gemini にフォールバックする。
- Gemini は Firebase AI (`FirebaseAI.firebaseAI(backend: .googleAI())`) 経由で使用する。
- 通知は `NotificationManager` と `UNUserNotificationCenter` を使い、必要に応じて AI 生成メッセージ・画像を添付する。
- サブスクリプションは StoreKit 2 と SwiftData の `UserSubscription` を同期する。

## 主要依存関係

| パッケージ | バージョン | 用途 |
|---|---:|---|
| `swift-composable-architecture` | `1.25.4` | 状態管理 / DI |
| `Alamofire` | `5.10.2` | HTTP 通信 |
| `PopupView` | `4.1.7` | ポップアップ表示 |
| `firebase-ios-sdk` | `12.0.0` | Firebase AI / App Check |

## 作業ワークツリー

- 機能実装・大きめの修正・実験的な変更は、原則として専用の git worktree を作って進める。
- このリポジトリには現時点で `.wtp.yml` がないため、通常は `git worktree add -b <topic> <path> HEAD` を使う。
- `<topic>` は作業内容が分かる短い名前にする。例: `fix-memo-notification`, `update-claude-md`。
- 既存の作業ツリーにユーザーの変更がある場合は、巻き戻しや上書きをせず、別 worktree で分離して作業する。
- コミット前には `git status` と差分を確認し、ユーザーの未関係な変更を含めない。
- 小さな調査・読み取りだけなら worktree を作らず現在の作業ツリーで対応してよい。

## ビルド・テスト・プレビュー

ビルド・テスト・プレビューは **xcode MCP ツール**を優先して使う。`xcodebuild` を直接実行するのは、xcode MCP で確認できない理由がある場合に限る。

### 基本フロー

1. `mcp__xcode__XcodeListWindows` でウィンドウ一覧を取得し、`tabIdentifier` を確認する。
2. `mcp__xcode__BuildProject` でビルドする。
3. `mcp__xcode__GetBuildLog` でエラー・警告を確認する。
4. `mcp__xcode__XcodeListNavigatorIssues` で Xcode ナビゲータ上の issue を確認する。

### よく使う xcode MCP ツール

| ツール | 用途 |
|---|---|
| `mcp__xcode__RunAllTests` | 全テスト実行 |
| `mcp__xcode__RunSomeTests` | 特定テスト実行 |
| `mcp__xcode__GetTestList` | テスト一覧取得 |
| `mcp__xcode__RenderPreview` | SwiftUI Preview のレンダリング |
| `mcp__xcode__ExecuteSnippet` | コードスニペットの実行 |
| `mcp__xcode__DocumentationSearch` | Apple Developer Documentation の検索 |
| `mcp__xcode__XcodeRead/Write/Update` | Xcode プロジェクト内ファイルの読み書き |
| `mcp__xcode__XcodeGlob/Grep/LS` | ファイル検索・内容検索 |
| `mcp__xcode__XcodeRefreshCodeIssuesInFile` | ファイルの code issue 更新 |

### Lint

```bash
swiftlint lint
```

テストターゲットは未整備。テストが必要な変更では、まず既存構成に合わせて最小の検証方法を用意する。

## コードスタイル

- SwiftLint (`.swiftlint.yml`) と SwiftFormat (`.swiftformat`) の設定に従う。
- Swift 6.1 / iOS 18.0+ を前提にする。
- UI は SwiftUI、永続化は SwiftData。
- コメント・UI テキストは日本語。
- Feature の public API は他モジュールからの参照範囲を意識し、不要に public を増やさない。
- 既存の TCA パターンから外れる場合は、理由が明確なときだけにする。

## コミットメッセージ

コミットメッセージは日本語で、絵文字と半角スペースに続けて具体的な変更内容を短く書く。

```text
:emoji: 変更内容の要約

Commit body...
```

例：

```text
👍 メモ詳細の通知設定を修正
```

| 絵文字 | 用途 |
|---|---|
| ✨ | 新規機能追加 |
| 🐛 | バグ修正 |
| 👍 | 機能修正 |
| ✏️ | タイポなどの修正 |
| 🎨 | リファクタリング |
| 🔥 | ファイル削除 |
| 📝 | ドキュメント追加 |
| 🔉 | ログ追加 |
| ✅ | テストの追加 |
| 🚀 | パフォーマンス改善 |
| 🚧 | コメントアウトなどの無効化 |
| 🔇 | ログ削除 |
| 👮 | セキュリティ関連の改善 |
| 🔖 | バージョンアップ |
| 🎉 | イニシャルコミット |

Subject には `新規追加` や `更新` のような固定語ではなく、具体的な変更内容を書く。

## PR メッセージ

PR タイトルはコミットメッセージの Subject と同じ絵文字・日本語表現を使用し、その後に具体的な内容を記述する。

```text
:emoji: Subject
```

PR 本文は日本語で、以下の形式に従う。

```markdown
## 概要

- 変更の目的や背景

## 変更内容

- 実装・修正した内容

## テスト

- 実行した確認内容
- 未実行の場合は理由を書く
```

## Skills

このリポジトリでは `browser-swift` 由来の skill セットから、SakuMemo に関係する iOS / Swift / SwiftUI / SwiftData / Apple Intelligence / App Store / テスト系を `.claude/skills/` と `.agents/skills/` に含めて管理する。`.claude/settings` や worktree などのローカル設定、ブラウザ・macOS・watchOS・visionOS 専用 skill は含めない。

以下の状況で対応するスキルを呼び出す。

| 状況 | スキル |
|---|---|
| TCA の Feature / Reducer / Dependency 実装 | `tca-feature` |
| Swift 言語パターン、Concurrency、SwiftData | `swift` |
| SwiftUI レイアウト、画面設計、Liquid Glass など UI | `design` |
| StoreKit、通知、AppIntents、権限まわり | `ios` |
| Firebase AI、App Check、API キー、セキュリティ | `security` |
| テストコードの追加・TDD | `testing` |
| 実装後のコードレビュー・整理 | `simplify` |

## 開発上の注意

- `Package.swift` の依存関係と README の記載がずれることがあるため、実装判断では `Package.swift` を優先する。
- `SearchFeature` は source 配下に存在するが、Package の target/product 登録や利用箇所を確認してから変更する。
- `Memo` は SwiftData の `@Model`。非同期処理や Repository 境界では `MemoSendable` への変換を優先する。
- `Memo.currentPriorityValue` は `createdAt` からの日数で減衰する。優先度低下・自動アーカイブの仕様変更時は `SwiftDataRepository.automaticPriorityValues()` も確認する。
- `AddMemoFeature.save` はサブスクリプションの無料枠チェック、カウント更新、AI タスク抽出をまとめて扱う。順序を変える場合は無料枠消費のタイミングに注意する。
- FoundationModels 対応コードは `#available(iOS 26.0, macOS 26.0, *)` で守る。
- Firebase / App Check / AdMob の初期化は `SakuMemoApp.swift` の `AppDelegate` に集約されている。
- UI テキストや AI プロンプトは日本語を基本にする。
