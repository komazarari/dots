---
name: day-end
description: GTD 日次締めスキル。一日の終わりに今日完了した Todoist タスクをまとめ、Project の次アクションを Todoist に登録し、Daily Note に記録する。`/day-end` と呼ばれたとき、またはユーザーが「今日の締め」「一日の終わり」「日次レビュー」「今日終わったタスクをまとめたい」「次のアクションを登録したい」と言ったときに使う。
allowed-tools: AskUserQuestion, Read, Write, Edit, Glob, Bash
---

# GTD 日次締めスキル

一日の終わりに3つのことを行う: 完了タスクの確認、Project の次アクション登録、Daily Note への記録。

## 引数

`/day-end YYYY-MM-DD` のように日付を渡した場合は、その日付を「今日」として処理する。
引数がない場合は `date +%Y-%m-%d` で取得した実行日を使う。

日付が確定したら冒頭に表示する:
```
📅 対象日: YYYY-MM-DD
```

## 環境情報

- **Obsidian Vault**: `/Users/takuto.komazaki/Obsidian_Main/`
- **Projects**: `gtd/Projects/` (ファイル名: `YYYY-MM_タイトル.md`)
- **Daily Notes**: `daily/` (ファイル名: `YYYY-MM-DD.md`)
- **Todoist プロジェクト**: `仕事` (ID: `6CrfCjRJmr4M9Vch`) / `プライベート` (ID: `6CrfCjRJmXfg5hg5`)
- **Todoistラベル**: `LOW_ENERGY` / `MID_ENERGY` / `HIGH_ENERGY`

---

## Step 1: 今日完了したタスクを取得する

`mcp__todoist__find-completed-tasks` で今日完了したタスクを取得する。
- `since` と `until` の両方に今日の日付 `YYYY-MM-DD` を指定する (日付のみ、時刻不要)
- `getBy: "completion"` を指定する (完了日で絞り込む)
- `projectId` は指定しない (全プロジェクト対象)

取得したタスクを仕事/プライベートに分類して表示する:

```
📋 今日の完了タスク (N件)
─────────────────────────
🏢 仕事 (X件)
  ✓ タスク名
  ✓ タスク名

🏠 プライベート (Y件)
  ✓ タスク名
```

完了タスクが0件の場合は「今日の完了タスクはありませんでした」と表示して Step 3 へ進む。

---

## Step 2: Project の次アクションを登録する

完了タスクがある場合、Project ファイルとの照合を行う。

### 2-1. Project ファイルをスキャンする

Glob で `gtd/Projects/*.md` を全件取得し、各ファイルの frontmatter の `todoist_action_id` を確認する。
`todoist_action_id` が完了タスクの ID と一致するファイルを探す。

```
🔍 Project との照合中...
```

一致するファイルが見つかった場合、そのファイルの `## Actions` セクションを読み込み、**最初のチェックされていない action** (` - [ ] ` で始まる行) を特定する。

### 2-2. 次アクションの処理

一致した Project ごとに以下を行う:

テキストで状況を表示する:
```
📁 プロジェクト: "プロジェクト名"
   完了: "完了したアクション名"
   次  : "次のアクション名"
```

次アクションが存在する場合、`AskUserQuestion` でTodoistへの登録を確認する:
- question: `"「次のアクション名」をTodoistに登録しますか?"`
- header: `"次アクション"`
- options:
  - label: "登録する", description: "Todoistに追加してプロジェクトファイルを更新する"
  - label: "スキップ", description: "今回は登録しない"

「登録する」を選んだ場合、プロジェクトとエネルギーを **1回の `AskUserQuestion`** で聞く:
- Q1: question: "どのTodoistプロジェクトに追加しますか?", header: "追加先"
  - options: 仕事 / プライベート
- Q2: question: "エネルギーレベルは?", header: "エネルギー"
  - options: LOW_ENERGY / MID_ENERGY / HIGH_ENERGY

`mcp__todoist__add-tasks` で登録する:
- content: `"プロジェクト名: 次アクション名"` (プロジェクト名を接頭辞にする)
- projectId: 選択した Todoist プロジェクト ID
- labels: 選択したエネルギーラベル

登録後、Edit ツールで Project ファイルの `todoist_action_id` を新しいタスク ID に更新する:
```
todoist_action_id: 新しいタスクID
```

次アクションが存在しない (全 Actions が完了済み) 場合:
```
🎉 "プロジェクト名" の全アクションが完了しています！
   プロジェクトを完了にしますか？
```
AskUserQuestion で確認し、「完了にする」を選んだら Project ファイルの frontmatter の `status` を `completed` に更新する。

### 2-3. 照合結果がない場合

`todoist_action_id` が一致する Project ファイルが見つからなかった場合は、そのまま Step 3 へ進む (完了タスクが Project に紐づいていないものだったということ)。

---

## Step 3: Daily Note に記録する

今日の Daily Note (`daily/YYYY-MM-DD.md`) に完了タスクと次アクション登録の内容を追記する。

### ファイルの存在確認

Read で `daily/YYYY-MM-DD.md` を読み込む:
- **存在する場合**: 末尾に追記する (既存の内容は変えない)
- **存在しない場合**: Write で新規作成する

### 追記フォーマット

```markdown

---

## 🌙 今日の締め (HH:MM)

### 完了タスク
**仕事**
- タスク名

**プライベート**
- タスク名

### 次アクション登録
- プロジェクト名 → 次アクション名 (エネルギーレベル)
```

時刻は `date +%H:%M` コマンドで取得する。
完了タスクが0件なら「完了タスクなし」と書く。
次アクション登録がなければ「次アクション登録なし」と書く。

---

## Step 4: 締めサマリーを表示する

```
✅ 日次締め完了
──────────────────────────────
完了タスク   : N件 (仕事 X件 / プライベート Y件)
次アクション : Z件 登録
Daily Note  : daily/YYYY-MM-DD.md に記録済み
──────────────────────────────
お疲れさまでした！🎉
```

---

## 注意点

- **Glob のパス**: Glob ツールは絶対パスを使う。例: `/Users/takuto.komazaki/Obsidian_Main/gtd/Projects` にパスを設定し、pattern は `**/*.md` とする
- **日付の決定**: 引数に `YYYY-MM-DD` が渡されていればそれを対象日とする。なければ `date +%Y-%m-%d` で取得する
- **時刻の取得**: `date +%H:%M` コマンドで現在時刻を取得する (引数日付に関わらず常に実行時刻)
- **frontmatter のパース**: ファイル先頭の `---` 〜 `---` の間を読んで `todoist_action_id:` の値を取り出す
- **Actions のパース**: `## Actions` セクション内の `- [ ] ` で始まる行を「未完了アクション」として扱う
- **Daily Note への追記**: Write ツールでは上書きになるため、既存ファイルへの追記は Read → 内容結合 → Write の手順で行う
- **完了タスクが大量の場合**: `hasMore: true` があれば続けて取得する
