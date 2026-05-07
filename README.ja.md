# Knowledge Goose

[English](./README.md) | [日本語](./README.ja.md)

> バンクーバーの独立系カフェ向けに、競合分析と可視化を提供するツール。

## 概要

**Knowledge Goose** は、バンクーバーで営業する単独店舗のカフェオーナーが、近隣の競合状況を構造化されたデータで把握できるようにするツールです。手動の現地観察データと Google Places API による公開情報を組み合わせ、来店促進の仮説立案に必要な事実ベースを提供します。

本プロジェクトは「自分で実装コードを書かずにプロダクトをリリースする」という実験の一環として、3 日 MVP として構築しています。コード生成と自己レビューは [ClaudeCode](https://www.anthropic.com/claude-code) に任せ、人間側は要件定義・設計・検証に集中する形を取っています。

## 主な機能(MVP)

- **MAP 表示**: すべての競合店をマップ上にピン表示、クリックで詳細を表示
- **時系列グラフ**: 客数・想定売上・Google レビュー数の推移を時系列で可視化
- **比較テーブル**: 自店と最大 3 件の競合店を、項目別に並べて比較

MVP では割愛している項目: 過去観察記録の編集・削除、CSV エクスポート、多言語 UI(Post-MVP で実装予定)。

## 技術スタック

| 領域                | 採用技術                                               |
| ------------------- | ------------------------------------------------------ |
| Framework           | Next.js 16(App Router)                                 |
| 言語                | TypeScript(strict mode)                                |
| DB                  | PostgreSQL on AWS RDS / PostgreSQL on Docker(ローカル) |
| ORM                 | Drizzle ORM                                            |
| 認証                | better-auth(メール+パスワード、Google OAuth)           |
| Transactional Email | Resend                                                 |
| UI                  | Tailwind CSS + shadcn/ui                               |
| フォーム            | react-hook-form + Zod                                  |
| 地図                | Google Maps JavaScript API + Places API                |
| グラフ              | Recharts                                               |
| Lint / Format       | ESLint + Prettier                                      |
| Hosting             | AWS Amplify Hosting                                    |

各選定の根拠は [docs/ja/stack.md](./docs/ja/stack.md) を参照。

## 前提環境

- Node.js 24 LTS(`.nvmrc` で固定)
- pnpm 9 以上
- Docker(ローカル PostgreSQL コンテナ用)
- Google Cloud アカウント(**Places API** と **Maps JavaScript API** が有効化されていること)
- Resend アカウント(transactional email 送信用)

## 起動手順

```bash
# リポジトリをクローン
git clone git@github.com:yk-graph/knowledge-goose.git
cd knowledge-goose

# 依存関係をインストール
pnpm install

# 環境変数をコピー・設定
cp .env.example .env.local
# .env.local を編集して、API キーと DB 接続情報を記入

# ローカル PostgreSQL コンテナを起動
docker compose up -d

# マイグレーション生成・適用、シードデータ投入
pnpm db:generate
pnpm db:migrate
pnpm db:seed

# 開発サーバを起動
pnpm dev
```

[http://localhost:3000](http://localhost:3000) で起動します。

> **メモ**: 新規登録したユーザーは自動的に `staff` ロールが付与されます。`admin` 権限を付与するには、DB に直接 SQL を実行してロールを更新します。詳細は [docs/ja/conventions.md](./docs/ja/conventions.md) を参照。

## スクリプト一覧

| コマンド           | 説明                                 |
| ------------------ | ------------------------------------ |
| `pnpm dev`         | 開発サーバ起動                       |
| `pnpm build`       | 本番ビルド                           |
| `pnpm start`       | 本番サーバ起動                       |
| `pnpm lint`        | ESLint 実行                          |
| `pnpm format`      | Prettier 実行                        |
| `pnpm typecheck`   | 型チェック(ファイル出力なし)         |
| `pnpm db:generate` | スキーマ変更からマイグレーション生成 |
| `pnpm db:migrate`  | 未適用マイグレーション実行           |
| `pnpm db:seed`     | シードデータ投入                     |
| `pnpm db:studio`   | Drizzle Studio(Web 版 DB GUI)起動    |

## ディレクトリ構成

```
knowledge-goose/
├── app/                  # Next.js App Router のページ・レイアウト
├── components/           # React コンポーネント(UI / 機能別)
├── actions/              # Next.js Server Actions
├── db/                   # Drizzle スキーマと DB クライアント
├── lib/                  # 外部サービス連携・ユーティリティ
├── schemas/              # Zod バリデーションスキーマ
├── types/                # 共通 TypeScript 型定義
├── docs/                 # 設計ドキュメント(英語、日本語版は ./ja 配下)
├── notes/                # 開発ブログ(英・日ペア)
├── drizzle/              # 自動生成されたマイグレーションファイル
├── public/               # 静的アセット
├── .claude/              # ClaudeCode のコマンドとスキル
├── CLAUDE.md             # ClaudeCode 用プロジェクト規約
├── AGENTS.md             # 汎用 AI エージェント向け指示
└── docker-compose.yml    # ローカル PostgreSQL 設定
```

詳細は [docs/ja/architecture.md](./docs/ja/architecture.md) を参照。

## ドキュメント

設計ドキュメントは `docs/` 配下に配置しています。英語版がメイン、日本語訳は `docs/ja/` 配下に並行配置。

- [プロダクト要件(PRD)](./docs/ja/prd.md)
- [データモデル](./docs/ja/data-model.md)
- [技術スタック](./docs/ja/stack.md)
- [アーキテクチャ](./docs/ja/architecture.md)
- [コーディング規約](./docs/ja/conventions.md)
- [API リファレンス](./docs/ja/api.md)
- [テスト戦略](./docs/ja/test-strategy.md)
- [デプロイガイド](./docs/ja/deployment.md)

## 開発ブログ

開発過程の判断と学びを記録した開発ブログを、`notes/` 配下に両言語で公開しています。

## ステータス

本プロジェクトは 3 日 MVP として開発中です。[PRD](./docs/ja/prd.md) で「Post-MVP」とマークされた機能は MVP には含めず、次期リリースで実装予定です。Post-MVP の優先度上位:

- 多言語 UI 対応(日本語 + 韓国語)
- 比較データの Excel / スプレッドシート形式エクスポート

## ライセンス

未確定。公開リリース前に LICENSE ファイルを追加します。
