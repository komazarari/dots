---
name: inbox
description: GTD inbox処理スキル。Todoistのinboxタスクを1件ずつ対話形式で処理し、Next Action・Project・WaitFor・Someday/Maybe・Referenceに振り分ける。`/inbox` と呼ばれたとき、またはユーザーが「inboxを処理したい」「GTDのinbox整理」「タスクを整理したい」と言ったときに使う。
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

タスクの内容を見て、以下の観点で簡潔にコメントする（1行）:
- 複数ステップが必要そうか → Project候補
- 誰かを待つ必要があるか → WaitFor候補
- アクション不要な情報か → Reference候補
- すぐできる具体的な行動か → Next Action候補

表示フォーマット:
```
[2/15] ──────────────────────────────
タスク: "タスク内容"
💡 複数ステップが必要そうです。Project が向いています。

  1. Next Action  (Todoistに追加)
  2. Project化    (gtd/Projects/ に新規作成)
  3. Waiting For  (gtd/WaitFor/ に新規作成)
  4. Someday/Maybe(gtd/SomeDay_Maybe/ に新規作成)
  5. Reference    (references/ に保存)
  6. 削除

> 
```

#### 2-2. 選択に応じて処理する

**1. Next Action を選んだ場合:**

```
プロジェクト:
  1. 仕事
  2. プライベート
> 

エネルギー:
  1. LOW_ENERGY
  2. MID_ENERGY
  3. HIGH_ENERGY
> 
```

- `mcp__todoist__add-tasks` で選択したプロジェクトにタスクを追加、ラベルを設定
- `mcp__todoist__delete-object` でinboxの元タスクを削除

**2. Project化 を選んだ場合:**

```
プロジェクト名 ["タスク内容から自動生成した候補"]: 
(Enterでデフォルト採用)

最初のNext Action: 
(具体的な次の行動を1つ入力)

このNext ActionをTodoistに追加しますか?
  1. 仕事
  2. プライベート
  3. あとで追加する
>
```

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
- `mcp__todoist__add-tasks` で追加してIDをfrontmatterに記録
- `mcp__todoist__delete-object` でinboxの元タスクを削除

**3. Waiting For を選んだ場合:**

```
誰を待っていますか?: 
期限 (例: 2026-04-15、なければEnter): 
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

```
"タスク内容" を削除します。よろしいですか? [y/N]
```

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
- **AIの提案はあくまで提案**: 番号選択後に内容を変更したいと言われたら柔軟に対応する
- **プロジェクト名の候補**: タスク内容から自然な日本語でファイル名にしやすい候補を出す
- **todoist_action_id**: Todoistにタスクを追加したらそのIDをProjectファイルに記録する(Weekly Reviewで追跡するため)
