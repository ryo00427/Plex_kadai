# backend — Rails 7.2 API

インターン生と企業をマッチングするスカウトサービスのバックエンド（API-only）です。

セットアップ手順・設計判断・API 仕様は、リポジトリルートの [README.md](../README.md) にまとめています。

## このディレクトリの構成

| パス | 役割 |
|------|------|
| `app/controllers/api/` | API エンドポイント（auth / interns / job_postings / conversations / messages） |
| `app/controllers/concerns/authenticatable.rb` | JWT からの `current_account` 解決と認証ガード |
| `app/models/` | Account / Intern / Company / JobPosting / Conversation / Message |
| `app/serializers/` | JSON レスポンス整形（PORO） |
| `app/services/json_web_token.rb` | JWT の発行・検証 |
| `db/` | マイグレーション / スキーマ / シードデータ |
| `spec/` | RSpec（models / requests / services）+ FactoryBot |

## よく使うコマンド

いずれもリポジトリルートで実行します（Docker 経由）。

```bash
# テスト（48 examples, 0 failures）
docker compose exec backend bundle exec rspec

# シードデータ投入
docker compose exec backend rails db:seed

# マイグレーション
docker compose exec backend rails db:migrate
```
