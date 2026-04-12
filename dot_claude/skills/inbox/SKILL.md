---
name: inbox
description: GTD inbox処理スキル。Todoistのinboxタスクを1件ずつ対話形式で処理し、Next Action・Project・WaitFor・Someday/Maybe・Referenceに振り分ける。`/inbox` と呼ばれたとき、またはユーザーが「inboxを処理したい」「GTDのinbox整理」「タスクを整理したい」と言ったときに使う。
allowed-tools: AskUserQuestion, Read, Bash
---

# GTD Inbox 処理スキル

Todoistのinboxを1件ずつ対話形式で処理する。ユーザーは「考える」のではなく「番号を選ぶだけ」で整理が完了する設計にする。

## 環境情報

- **Obsidian Vault**: `/Users/takuto.komazaki/Obsidian_Main/`
- **Projects**: `gtd/Projects/`
- **WaitFor**: `gtd/WaitFor/`
- **SomeDay_Maybe**: `gtd/SomeDay_Maybe/`
- **Reference**: `references/`
- **Todoistラベル**: `LOW_ENERGY` / `MID_ENERGY` / `HIGH_ENERGY`
- **Todoistプロジェクト**: `仕事` / `プライベート`

## 処理フロー

### Step 1: Inboxを取得する

`mcp__todoist__find-tasks` で `projectId: "inbox"` を指定してタスクを全件取得する。
件数を表示して処理を開始する。

```
📥 Inbox: N件
─────────────────
```

### Step 2: 1件ずつ処理する

各タスクについて以下の順で進める。

#### 2-1. タスクを表示してAIが分析する

タスクの内容を見て、以下の観点で1行コメントする:
- 複数ステップが必要そうか → Project候補
- 誰かを待つ必要があるか → WaitFor候補
- アクション不要な情報か → Reference候補
- すぐできる具体的な行動か → Next Action候補

テキストでカウンターとコメントを表示してから `AskUserQuestion` を呼ぶ:

```
[2/15] ──────────────────────────────
タスク: "タスク内容"
💡 複数ステップが必要そうです。Project が向いています。
```

`AskUserQuestion` で処理方法を聞く:
- question: "このタスクをどう処理しますか?"
- header: "処理方法"
- options (4択 + 自動追加のOther):
  - label: "Next Action", description: "Todoistの仕事/プライベートに追加"
  - label: "Project化", description: "gtd/Projects/ に新規ファイルを作成"
  - label: "Waiting For", description: "gtd/WaitFor/ に新規ファイルを作成"
  - label: "Someday/Maybe", description: "gtd/SomeDay_Maybe/ に新規ファイルを作成"
- Reference は Other で "Reference" と入力、削除は Other で "削除" と入力して対応

#### 2-2. 選択に応じて処理する

**1. Next Action を選んだ場合:**

プロジェクトとエネルギーを **1回の `AskUserQuestion`** で同時に聞く (2問同時):
- Q1: question: "どのプロジェクトに追加しますか?", header: "プロジェクト"
  - options: 仕事 / プライベート
- Q2: question: "エネルギーレベルは?", header: "エネルギー"
  - options: LOW_ENERGY / MID_ENERGY / HIGH_ENERGY

- `mcp__todoist__update-tasks` で元のinboxタスクの `projectId` と `labels` を更新する (新規作成・削除は不要)
- これにより1回のAPI呼び出しでタスクの移動とラベル付けが完了する

**2. Project化 を選んだ場合:**

プロジェクト名を `AskUserQuestion` で聞く:
- question: "プロジェクト名を決めてください", header: "プロジェクト名"
- options:
  - label: "[候補名]", description: "このまま採用"
  - (Other で新しい名前を入力)

続いて最初のNext Actionをテキストで聞く (自由入力のため通常のテキストプロンプト):
```
最初のNext Action (具体的な次の一歩):
> 
```

Next ActionのTodoist追加先とエネルギーを **1回の `AskUserQuestion`** で同時に聞く (2問同時):
- Q1: question: "Next ActionをどのTodoistプロジェクトに追加しますか?", header: "追加先"
  - options: 仕事 / プライベート / あとで追加する
- Q2: question: "エネルギーレベルは?", header: "エネルギー"
  - options: LOW_ENERGY / MID_ENERGY / HIGH_ENERGY
  - ※ "あとで追加する" を選んだ場合はQ2の回答を無視する

以下のファイルを作成する (Vault相対パス: `gtd/Projects/YYYY-MM_タイトル.md`):

タスク内容から「目的・ゴール」を推測して記入する。ただし以下の場合はユーザーに確認する:
- タスク名が短すぎて意図が読めない (例: "確認する", "対応")
- 略語や固有名詞が多く文脈が不明

確認する場合: `このプロジェクトのゴールを教えてください (例: ...)` と具体的な例を添えて聞く。

```markdown
---
created: YYYY-MM-DD
status: active
importance: medium
todoist_action_id: (TodoistのタスクIDがあれば記録)
---
# プロジェクト名

## 目的・ゴール
(タスク内容から推測して記入。推測しにくい場合はユーザーに確認してから記入)

## 完了条件
- [ ] 

## Actions
- [ ] 最初のNext Action
(続くActionがあれば列挙するよう促す)

## メモ
```

Todoist追加を選んだ場合はエネルギーラベルも選択させる。
- `mcp__todoist__update-tasks` で元のinboxタスクの `projectId`・`labels`・`content`(プロジェクト名を接頭辞にした形) を更新して移動する
- 取得したタスクIDをProjectファイルの `todoist_action_id` に記録する
- **「あとで追加する」を選んだ場合**: `mcp__todoist__delete-object` でinboxから削除する (Projectファイルの `todoist_action_id` は空のまま)

**3. Waiting For を選んだ場合:**

相手名と期限は自由入力のため通常のテキストプロンプトで聞く:
```
誰を待っていますか?: 
期限 (例: 2026-04-15、なければスキップ): 
```

以下のファイルを作成する (Vault相対パス: `gtd/WaitFor/YYYY-MM_タイトル.md`):

```markdown
---
created: YYYY-MM-DD
waiting_for: 誰に
due: YYYY-MM-DD
status: waiting
---
# 件名

## 待っている内容
(タスク内容を記入)

## 背景・経緯
```

- `mcp__todoist__delete-object` でinboxの元タスクを削除
- **期限の扱い**: `due` が設定されている場合、Weekly Reviewスキルで期限超過・期限近接を検知してアラートできる。`due` は必ず ISO 8601形式 (`YYYY-MM-DD`) で記録する。

**4. Someday/Maybe を選んだ場合:**

以下のファイルを作成する (Vault相対パス: `gtd/SomeDay_Maybe/YYYY-MM_タイトル.md`):

```markdown
---
created: YYYY-MM-DD
---
# タイトル

## 詳細・背景
(タスク内容を記入)
```

- `mcp__todoist__delete-object` でinboxの元タスクを削除

**5. Reference を選んだ場合:**

```
カテゴリ/タグ (例: 技術, 読書, 仕事): 
```

以下のファイルを作成する (Vault相対パス: `references/YYYY-MM_タイトル.md`):

```markdown
---
created: YYYY-MM-DD
tags: [入力したタグ]
---
# タイトル

## 内容
(タスク内容を記入。URLやリンクがあれば保持)
```

- `mcp__todoist__delete-object` でinboxの元タスクを削除

**6. 削除 を選んだ場合:**

`AskUserQuestion` で確認する:
- question: "'タスク内容' を削除します。よろしいですか?", header: "確認"
- options: 削除する / キャンセル

確認後、`mcp__todoist__delete-object` で削除。

### Step 3: 完了後のサマリー

全件処理後にサマリーを表示する:

```
✅ Inbox処理完了 (N件)
──────────────────────
Next Action : X件 → Todoist
Project化   : X件 → gtd/Projects/
Waiting For : X件 → gtd/WaitFor/
Someday/Maybe: X件 → gtd/SomeDay_Maybe/
Reference   : X件 → references/
削除        : X件
```

## 重要な注意点

- **中断は自然に**: ユーザーが「今日はここまで」と言ったら残りを残してサマリーを出す
- **hasMore対応**: Todoistの取得結果に `hasMore: true` がある場合は続けて取得する
- **ファイル作成はWrite tool**: ローカルファイルの作成にはWrite toolを使う
- **AIの提案はあくまで提案**: 選択後に内容を変更したいと言われたら柔軟に対応する
- **プロジェクト名の候補**: タスク内容から自然な日本語でファイル名にしやすい候補を出す
- **todoist_action_id**: Todoistにタスクを追加したらそのIDをProjectファイルに記録する(Weekly Reviewで追跡するため)
