---
name: weekly-review
description: GTD Weekly Reviewスキル。毎週のGTDレビューを対話形式でガイドする。WaitFor期限チェック・Project次アクション確認・SomeDayレビューをAIが自動スキャンして提示する。`/weekly-review` または `/weekly-review YYYY-MM-DD` で起動。「週次レビュー」「ウィークリーレビュー」「今週の振り返り」と言われたときも使う。
---

# GTD Weekly Review スキル

毎週のGTDレビューを対話形式でガイドする。軽快に、かつ抜け漏れなく進めることを目指す。

## 環境情報

- **Obsidian Vault**: `$HOME/Obsidian_Main/`
- **テンプレート**: `.templates/gtd_weekly_review.md`
- **出力先**: `gtd/WeeklyReview/YYYY-MM-DD_WeeklyReview.md`
- **Projects**: `gtd/Projects/`
- **WaitFor**: `gtd/WaitFor/`
- **SomeDay_Maybe**: `gtd/SomeDay_Maybe/`

## 起動時の処理

### 日付の決定

- 引数あり (`/weekly-review 2026-04-05`): その日付を使う
- 引数なし: 今日の日付を使う

### レビューファイルの準備

対象ファイル: `gtd/WeeklyReview/YYYY-MM-DD_WeeklyReview.md`

- **ファイルが存在する場合**: そのファイルを使って続きから再開する。「既存のレビューファイルを見つけました。続きから進めます。」と伝える。
- **ファイルが存在しない場合**: `.templates/gtd_weekly_review.md` をコピーして作成する。

---

## Phase 1: 収集・片付け

レビューファイルの「収集、片付け、把握する」セクションのチェックリストを表示する。

```
📋 収集・片付けチェックリスト
─────────────────────────────
完了したら Enter、スキップは s、終了は q

  [ ] Business Gmail
  [ ] Private Gmail
  ...
```

このフェーズはユーザーのペースで進める。チェックが終わったらファイルの `[ ]` を `[x]` に更新する。

「思いついたことはTodoist inboxへ」と随時リマインドする。ユーザーがその場でinboxに追加したい場合は `mcp__todoist__add-tasks` でinboxに追加する。

「頭の中」セクションのTrigger Listは自動スキャンで代替するため、スキップしてよい。ただしユーザーが「ブレインダンプしたい」と言ったら時間を取る。

---

## Phase 2: AIスキャン

「ではAIスキャンを行います」と伝えて、以下を並行してスキャンする。

### 2-1. Inbox 整理
`/inbox` Skill を使い、inbox の内容を処理する。もしも `/inbox` Skill が見付からない場合はユーザに inbox の整理を促す。

### 2-2. WaitFor チェック

`gtd/WaitFor/` 配下の全 `.md` ファイルを読んで frontmatter の `due` と `status` を確認する。

表示フォーマット:
```
⏰ Waiting For スキャン (N件)
─────────────────────────────
🔴 期限超過
  - "山田さんへの見積もり依頼" (due: 2026-03-30, waiting_for: 山田さん)
    → どうしますか? 1.催促する 2.期限延長 3.解決済みで削除

🟡 今週中 (〜YYYY-MM-DD)
  - "AWSの見積もり" (due: YYYY-MM-DD, waiting_for: ベンダー)

⚪ それ以降
  - ...
```

各アイテムへの対応に応じて:
- 催促する → メモとしてコメントを追記してOK
- 期限延長 → ファイルの `due` を更新
- 解決済み → `status: done` にしてファイルを `z_archived/` 相当に移動するか確認

### 2-3. Projects チェック

`gtd/Projects/` 配下の全 `.md` ファイルを読んで frontmatter の `status`, `importance`, `todoist_action_id` と本文の Actions チェックリストを確認する。

スキャン観点:
- `status: active` なのに `todoist_action_id` がない → 次のActionをTodoistに追加すべき
- Actions リストの最初のunchecked itemがTodoistのIDと一致しているか (IDがあれば `mcp__todoist__fetch-object` で確認)
- `importance: high` なのにActionが止まっているものは特に注意

表示フォーマット:
```
📁 Projects スキャン (N件)
─────────────────────────────
⚠️ 次のActionが未設定
  - "sava jenkins terraform移行" [importance: high]
    Actions: "- [ ] importコマンドを書く"
    → Todoistに追加しますか? 1.仕事 2.プライベート 3.スキップ

✅ 正常 (Todoistにアクション設定済み)
  - "webshop PWAサポート" → Todoist: "PWA manifest を調査する"
```

importance別に整理して表示する (high → medium → low の順)。

### 2-3. SomeDay/Maybe レビュー

`gtd/SomeDay_Maybe/` 配下の全 `.md` ファイルを一覧表示する。

```
💭 Someday/Maybe レビュー (N件)
─────────────────────────────
作成日の古い順に表示。気になるものを選んでください。

  1. "数学教室πを読む" (2026-03-15)
  2. "Bluestacksを試す" (2026-03-20)
  ...

→ 番号でActivate、s でスキップ、q で終了
```

Activateを選んだ場合: inboxスキルの「1. Next Action」または「2. Project化」と同じフローで処理する。

### 2-4. Todoist 確認

`mcp__todoist__find-tasks` で仕事・プライベートのタスクを取得して軽く確認する。

```
✅ Todoist Next Actions (N件)
─────────────────────────────
仕事 (X件):
  - "importコマンドを書く" [HIGH_ENERGY]
  - ...

プライベート (X件):
  - ...

→ 気になるタスクがあれば番号で操作 (優先度変更・削除・今日に設定)
   Enterでスキップ
```

---

## Phase 3: 振り返り (KPT)

軽量に。長文は不要。

```
📝 振り返り (KPT)
─────────────────────────────
Keep (続けること): 
Problem (改善したいこと): 
Try (来週試すこと): 

(空白のままEnterでスキップ可)
```

入力内容をレビューファイルの「振り返り」セクションに追記する。

---

## 完了

```
✅ Weekly Review 完了
─────────────────────────────
レビューファイル: gtd/WeeklyReview/YYYY-MM-DD_WeeklyReview.md

スキャン結果:
  WaitFor   : X件 (うち期限超過 Y件)
  Projects  : X件 (うちAction未設定 Y件)
  Someday   : X件 (うちActivate Y件)

お疲れさまでした 🎉
```

---

## 注意事項

- **ファイルの読み込み**: Glob → Read の順でスキャンする。frontmatterのパースはYAML形式として手動で解析する
- **スキップは常に可能**: 各フェーズでユーザーが「スキップ」「次へ」と言ったら次のフェーズに進む
- **中断も自然に**: 途中で終わりたいと言われたら、それまでの変更を保存してサマリーを出す
- **ファイル操作**: ローカルファイルの作成・更新にはWrite/Edit toolを使う
- **Todoist操作**: MCPツールが利用できない場合は「Todoistへの操作はスキップします」と伝えて続行する
