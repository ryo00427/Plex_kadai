# インターン生と企業をマッチングするスカウトサービス — 設計ドキュメント

- **日付**: 2026-07-18
- **課題**: 株式会社プレックス インターン技術課題
- **方針**: 機能を絞り込み、設計・コードの質でアピールする

## 1. 目的とスコープ

インターン生と企業をマッチングするスカウトサービスのプロトタイプ。

### スコープに含む
- インターン生の登録
- 企業からインターン生へのメッセージ送信(会話スレッド、インターンも返信可)
- 企業の募集掲載(CRUD)

### スコープに含まない(将来課題)
- インターン/募集の検索・絞り込み
- 予定調整、グループチャット
- OpenAPI からの型自動生成
- httpOnly Cookie ベースのセッション管理

## 2. 技術スタック

| レイヤ | 技術 |
|--------|------|
| バックエンド | Rails 7 (API-only)、Ruby 3.x |
| DB | PostgreSQL |
| フロントエンド | Next.js (App Router)、TypeScript (strict)、Tailwind CSS |
| 認証 | JWT (bcrypt) |
| API | REST (JSON) |
| テスト | RSpec + FactoryBot (BE)、Vitest + React Testing Library (FE) |
| 実行環境 | Docker Compose (postgres + backend + frontend) |
| 静的解析 | Rubocop、ESLint |

## 3. ドメインモデル(採用: 案A)

認証情報を `Account` に集約し、ロール固有のプロフィールを分離する。

```
accounts (id, email, password_digest, role[intern|company])
  └─ has_one :profile (polymorphic: profileable)

interns   (id, account_id, name, university, major, graduation_year, skills, bio)
companies (id, account_id, name, industry, description, website)

conversations (id, company_id, intern_id)      # unique index [company_id, intern_id]
messages      (id, conversation_id, sender_type, sender_id, body, read_at, created_at)

job_postings  (id, company_id, title, description, requirements,
               location, employment_type, status[draft|published])
```

### 採用理由
- メール一意制約・パスワードハッシュ・JWT 発行が `Account` の1箇所に集約され DRY。
- JWT のペイロードは `account_id` のみで完結。
- ロール固有データがプロフィールテーブルに分離され、責務が明確でテストしやすい。

### 関連
- `Account has_one :profileable`(polymorphic)、`Intern`/`Company` が `belongs_to :account`。
- `Company has_many :conversations`、`Intern has_many :conversations`。
- `Conversation has_many :messages`。`Message belongs_to :sender`(polymorphic: Intern or Company)。
- `Company has_many :job_postings`。

## 4. メッセージング設計

課題要件は「企業→インターン」だが、スカウトサービスの本質は往復のやり取りであるため、
会話スレッド (`conversations`) + メッセージ (`messages`) の構造とする。

- 会話は **企業がインターンに対して開始** する。
- 同一の (company, intern) 間の会話は unique index で1本に制限。
- インターンは自分の会話内で **返信可能**。
- `messages.read_at` で既読管理。

## 5. REST API

すべて `/api` 配下。認証が必要なエンドポイントは `Authorization: Bearer <JWT>` を要求。

### 認証
| メソッド | パス | 説明 |
|----------|------|------|
| POST | `/api/auth/register` | `role` + email/password + プロフィール項目で登録 |
| POST | `/api/auth/login` | `{ token, account }` を返す |
| GET  | `/api/me` | 現在のアカウント + プロフィール |

### インターン
| メソッド | パス | 認可 |
|----------|------|------|
| GET   | `/api/interns` | 企業のみ(スカウト候補一覧) |
| GET   | `/api/interns/:id` | 企業のみ |
| PATCH | `/api/interns/me` | 本人のみ |

### 企業・募集
| メソッド | パス | 認可 |
|----------|------|------|
| GET    | `/api/companies/:id` | 認証済み |
| PATCH  | `/api/companies/me` | 本人のみ |
| GET    | `/api/job_postings` | 公開(published のみ) |
| GET    | `/api/job_postings/:id` | 公開 |
| POST   | `/api/companies/me/job_postings` | 企業本人のみ |
| PATCH/DELETE | `/api/job_postings/:id` | 所有企業のみ |

### メッセージ
| メソッド | パス | 認可 |
|----------|------|------|
| GET  | `/api/conversations` | 参加者のみ(自分の会話一覧) |
| POST | `/api/conversations` | 企業のみ(intern を指定して開始) |
| GET  | `/api/conversations/:id/messages` | 参加者のみ |
| POST | `/api/conversations/:id/messages` | 参加者のみ |

### 認可方針
`current_account` を基準に、各コントローラで明示的なガード(軽量ポリシー)を行う。
所有権チェック(自分のプロフィール/会話/募集か)を共通ヘルパに切り出す。

## 6. フロントエンド

- **型安全な API クライアント**: `fetch` ラッパー + 手書きの共有型(`src/types`)。OpenAPI 自動生成は将来課題。
- **認証状態**: JWT を `localStorage` 保持、Authorization ヘッダで送信。
  - セキュリティ上のトレードオフ(XSS リスク)は README に明記し、本番では httpOnly Cookie を推奨する旨を記載。
- **画面構成**
  - 共通: `/`(ランディング)、`/register`(ロール選択→フォーム)、`/login`
  - インターン向け: プロフィール編集、募集一覧・詳細、メッセージ一覧・スレッド
  - 企業向け: インターン一覧→詳細(スカウト開始)、募集管理(作成/編集)、メッセージ

## 7. テスト戦略

- **バックエンド (RSpec)**: モデルスペック(バリデーション・関連)、リクエストスペック(認証・認可・メッセージ・募集の主要フロー)。FactoryBot でデータ生成。
- **フロントエンド (Vitest + RTL)**: API クライアントのユニットテスト、主要フォーム(登録・ログイン・メッセージ送信)のコンポーネントテスト。
- e2e (Playwright) は任意・将来課題。

## 8. ツール・DX

- **Docker Compose** で postgres + backend + frontend をワンコマンド起動。
- `db:seed` でデモ用データ(インターン・企業・募集・会話)を投入。
- Rubocop / ESLint / Prettier / TypeScript strict を設定。
- README に設計意図・ドメイン図・セットアップ手順を記載(アピール文書)。

## 9. リポジトリ構成

```
/
├── backend/            # Rails API-only
├── frontend/           # Next.js App Router
├── docs/               # 設計ドキュメント
├── docker-compose.yml
└── README.md
```
