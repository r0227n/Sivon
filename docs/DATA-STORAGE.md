# Sivon Data Storage

## 目的

このドキュメントは、Sivon のデータ保管方針を記録する。対象はタスクデータ、アプリ設定、永続化エラー時の振る舞いである。

## 保存対象

Sivon には現在 2 種類の永続データがある。

| 種類 | 保存先 | 理由 |
| --- | --- | --- |
| タスク | SwiftData | ローカルで構造化されたタスクを永続化し、将来の拡張にも耐えるため。 |
| アプリ言語設定 | UserDefaults | 小さなユーザー設定であり、タスクモデルとは独立しているため。 |

```mermaid
flowchart LR
    TaskData["Task Data\nTodoTask"]
    AppSettings["App Settings\nAppLanguage"]
    SwiftData["SwiftData\nPersistedTask"]
    UserDefaults["UserDefaults\nappLanguage"]

    TaskData --> SwiftData
    AppSettings --> UserDefaults
```

## タスクモデル

ドメイン上のタスクは `TodoTask`、SwiftData 上の保存モデルは `PersistedTask` で表す。

`TodoTask` の主なフィールド:

- `id`: `UUID`
- `title`: タスク名。空文字や空白のみは保存しない。
- `notes`: 補足メモ。現在は空文字を許容する。
- `isCompleted`: 完了状態。
- `dueDate`: 期限日。未設定の場合は `nil`。
- `createdAt`: 作成日時。
- `updatedAt`: 最終更新日時。

`PersistedTask` は SwiftData の `@Model` であり、`id` に `@Attribute(.unique)` を付ける。

```mermaid
classDiagram
    class TodoTask {
        UUID id
        String title
        String notes
        Bool isCompleted
        Date? dueDate
        Date createdAt
        Date updatedAt
    }

    class PersistedTask {
        UUID id
        String title
        String notes
        Bool isCompleted
        Date? dueDate
        Date createdAt
        Date updatedAt
        domainValue TodoTask
        update(from TodoTask)
    }

    TodoTask <--> PersistedTask : map on fetch and save
```

## 判断

SwiftData のモデルと TCA の状態は分離する。

理由:

- reducer のテストや状態遷移を SwiftData に依存させない。
- SwiftData の `@Model` は永続化都合の型であり、UI の表示判定やソートとは責務が異なる。
- 将来ストレージを変更する場合も、`TaskPersistenceClient` の実装差し替えで影響範囲を抑えられる。

## 永続化フロー

起動時:

```mermaid
sequenceDiagram
    participant App as SivonApp
    participant Store as TCA Store
    participant Feature as AppFeature
    participant Client as TaskPersistenceClient
    participant Repo as SwiftDataTaskRepository

    App->>App: ModelContainer(for: PersistedTask.self)
    App->>Store: AppFeature(taskPersistence: .live)
    Store->>Feature: onAppear
    Feature->>Client: fetchAll()
    Client->>Repo: fetchAll()
    Repo-->>Client: [TodoTask]
    Client-->>Feature: [TodoTask]
    Feature->>Store: tasksLoaded([TodoTask])
```

更新時:

```mermaid
sequenceDiagram
    participant User as User
    participant View as SwiftUI View
    participant Feature as AppFeature
    participant Client as TaskPersistenceClient
    participant Repo as SwiftDataTaskRepository
    participant SwiftData as SwiftData

    User->>View: edit / complete / reschedule / delete
    View->>Feature: AppFeature.Action
    Feature->>Feature: update State immediately
    Feature->>Client: upsert(task) or delete(id)
    Client->>Repo: persist operation
    Repo->>SwiftData: insert / update / delete
    Repo->>SwiftData: save()
    alt save fails
        Repo-->>Feature: error
        Feature->>Feature: userMessage = saveFailed
        Feature->>Client: fetchAll()
    end
```

UI は操作直後に反映する。保存に失敗した場合は `persistenceFailed` を出し、SwiftData から再読み込みして整合性を戻す。

## 日付の扱い

ビュー判定では時刻を無視し、`Calendar.current.startOfDay(for:)` または `Calendar.isDate(_:inSameDayAs:)` を使う。

重要なルール:

- `today`: `dueDate` が今日、かつ未完了。
- `overdue`: `dueDate` が今日より前、かつ未完了。
- `dueDate == nil`: 今日ビューと期限切れビューには表示しない。
- `completed`: 期限日に関係なく完了済み。

この判定は `TaskDomain.swift` に集約し、view 側で再実装しない。

```mermaid
flowchart TD
    Task["TodoTask"]
    Completed{"isCompleted?"}
    HasDue{"dueDate exists?"}
    DueToday{"dueDate is today?"}
    DuePast{"dueDate before today?"}
    CompletedView["Completed View"]
    TodayView["Today View"]
    OverdueView["Overdue View"]
    AllView["All Tasks View"]
    HiddenFromDateViews["Hidden from Today / Overdue"]

    Task --> AllView
    Task --> Completed
    Completed -- yes --> CompletedView
    Completed -- no --> HasDue
    HasDue -- no --> HiddenFromDateViews
    HasDue -- yes --> DueToday
    DueToday -- yes --> TodayView
    DueToday -- no --> DuePast
    DuePast -- yes --> OverdueView
    DuePast -- no --> HiddenFromDateViews
```

## アプリ設定

言語設定は `AppLanguage.storageKey` をキーに `UserDefaults` へ保存する。

保存値:

- `system`
- `english`
- `japanese`

`SivonApp` は保存値から `Locale` を導出し、`ContentView` と `SettingsView` に `.environment(\.locale, selectedLanguage.locale)` を渡す。

## 変更時の注意

- タスクのフィールドを追加する場合は `TodoTask` と `PersistedTask` の両方を更新する。
- `PersistedTask.domainValue` と `PersistedTask.update(from:)` の対応漏れを作らない。
- SwiftData migration が必要な変更では、既存ユーザーのローカルデータを壊さない方針を先に決める。
- タスク以外の小さな設定値を安易に `PersistedTask` に追加しない。
