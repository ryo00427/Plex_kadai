# frontend — Next.js (App Router)

インターン生と企業をマッチングするスカウトサービスのフロントエンドです。

セットアップ手順・設計判断・API 仕様は、リポジトリルートの [README.md](../README.md) にまとめています。

## このディレクトリの構成

| パス | 役割 |
|------|------|
| `src/app/` | ルーティング（register / login / interns / jobs / company/jobs / messages） |
| `src/components/` | 画面をまたいで使うコンポーネント（RegisterForm など） |
| `src/lib/api.ts` | 型安全な fetch ラッパー（`apiFetch` / `ApiError`） |
| `src/lib/auth.tsx` | 認証コンテキスト（JWT の保持・復元、login / register / logout） |
| `src/lib/hooks.ts` | データ取得フック `useApi`（中断・エラーリセット対応） |
| `src/types/` | バックエンドのレスポンスに対応する共有型 |

## よく使うコマンド

いずれもリポジトリルートで実行します（Docker 経由）。

```bash
# テスト（6/6 passing）
docker compose exec frontend npm run test

# ビルド確認（型チェックを兼ねる）
docker compose exec frontend npm run build
```

開発サーバーは `docker compose up` で起動し、http://localhost:3000 で確認できます。
