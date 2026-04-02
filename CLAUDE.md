# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

ビルド・テスト・プレビューは **xcode MCP ツール**を優先して使うこと（`xcodebuild` などのbashコマンドより確実）。

### 基本フロー

1. **tabIdentifier の取得** — `mcp__xcode__XcodeListWindows` でウィンドウ一覧を取得し、`tabIdentifier` を確認する
2. **ビルド** — `mcp__xcode__BuildProject` でビルド実行
3. **ビルドログ確認** — `mcp__xcode__GetBuildLog` でエラー・警告を確認
4. **Xcodeナビゲータのissue確認** — `mcp__xcode__XcodeListNavigatorIssues` でXcode上の問題を確認

### その他の xcode MCPツール

| ツール | 用途 |
|---|---|
| `mcp__xcode__RunAllTests` | 全テスト実行 |
| `mcp__xcode__RunSomeTests` | 特定テスト実行 |
| `mcp__xcode__GetTestList` | テスト一覧取得 |
| `mcp__xcode__RenderPreview` | SwiftUI Previewのレンダリング |
| `mcp__xcode__ExecuteSnippet` | コードスニペットの実行 |
| `mcp__xcode__DocumentationSearch` | Apple Developer Documentationの検索 |
| `mcp__xcode__XcodeRead/Write/Update` | Xcodeプロジェクト内ファイルの読み書き |
| `mcp__xcode__XcodeGlob/Grep/LS` | ファイル検索・内容検索 |
| `mcp__xcode__XcodeRefreshCodeIssuesInFile` | ファイルのコードissueを更新 |

### Lint

```bash
swiftlint lint
```

テストターゲットは未整備。

## Architecture

TCA (The Composable Architecture) を使ったSPMマルチモジュール構成のiOSアプリ。

### モジュール構成（SakuMemoPackage/Sources/）

- **AppFeature** — ルートのタブ管理。MemoFeature, ArchiveFeature, SettingsFeatureをScopeで合成
- **MemoFeature** — メモ一覧（ホームタブ）。AI分析、タスク抽出、通知管理を統合
- **AddMemoFeature** — メモ作成モーダル + AI タスク抽出
- **MemoDetailFeature** — メモ編集・通知設定
- **ArchiveFeature** — アーカイブ済みメモ一覧
- **SettingsFeature** — 設定画面
- **SubscriptionFeature** — サブスクリプション管理（StoreKit 2）
- **SearchFeature** — 検索・フィルタリング
- **Repository** — データアクセス実装（SwiftData, Gemini API, FoundationModels, StoreKit, 通知）
- **RepositoryProtocol** — Repositoryのプロトコル定義（DI用）
- **SharedModel** — 共有データモデル（Memo, UserSubscription等）
- **Components** — 再利用UIコンポーネント
- **Utils** — ヘルパー・カスタムModifier

### TCA実装パターン

- `@Reducer` + `@ObservableState` + `@Dependency` を使用
- Viewは `ViewAction` パターン（`.view(.actionName)`）でアクション送信
- バインディングは `BindableAction` + `BindingReducer()` + `@Bindable var store`
- モーダル表示は `@Presents` + `PresentationAction`
- **TCA実装の参考**: プロジェクト内の `.tca-reference/` フォルダ（特に `Examples/SyncUps/`）を参照すること

### 依存性注入

Repository層は `@DependencyClient` マクロでラップし、`DependencyValues` extensionで登録。Feature内では `@Dependency(\.xxxRepository)` で取得。

## Code Style

- SwiftLint（`.swiftlint.yml`）とSwiftFormat（`.swiftformat`）で管理
- Swift 6.1 / iOS 18.0+
- UIはSwiftUI、データ永続化はSwiftData
- コメント・UIテキストは日本語
