# AWS Lambda Web Adapter Workshop

FastAPIアプリケーションをAWS Lambda Web Adapterを使用してAWS Lambdaにデプロイするワークショップです。

## 概要

このプロジェクトは、従来のWebアプリケーションをコード変更なしでAWS Lambda上で実行する方法を学ぶためのハンズオンワークショップです。connpassのイベント情報を取得するREST APIを構築し、AWS Lambda Web Adapterを使用してサーバーレス環境にデプロイします。

## 特徴

- **FastAPI**: 高性能なPython Webフレームワーク
- **AWS Lambda Web Adapter**: 標準的なWebアプリケーションをLambdaで実行
- **コンテナベース**: DockerコンテナとしてLambdaにデプロイ
- **AWS SAM**: Infrastructure as Codeによる簡単なデプロイ

## 前提条件

- Python 3.12
- AWS CLI設定済み
- AWS SAM CLI
- Docker
- AWSアカウント（Lambda、API Gateway、ECRの権限）

## クイックスタート

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd hmddev-lambda-web-adapter-workshop
```

### 2. ローカル開発環境のセットアップ

```bash
# 仮想環境の作成
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 依存関係のインストール
pip install -r app/requirements.txt
```

### 3. ローカルでの実行

```bash
cd app
uvicorn main:app --reload --port 8080
```

ブラウザで `http://localhost:8080/docs` にアクセスして、API仕様を確認できます。

### 4. AWSへのデプロイ

```bash
# アプリケーションのビルド
sam build

# 初回デプロイ（対話形式）
sam deploy --guided --role-arn arn:aws:iam::$ACCOUNT_ID:role/workshop-cfn-execution-role

# 2回目以降のデプロイ
sam deploy
```

## API エンドポイント

デプロイ後、以下のエンドポイントが利用可能になります：

| メソッド | パス | 説明 |
|---------|------|------|
| GET | `/events` | イベント一覧を取得（キーワード検索可） |
| GET | `/events/{event_id}/detail` | イベントの詳細情報を取得 |
| GET | `/events/pref/{prefecture}` | 都道府県別のイベントを取得 |
| GET | `/events/group/{subdomain}` | グループ別のイベントを取得 |
| GET | `/events/count` | イベントの総数を取得 |
| POST | `/events/filter` | 高度なフィルタリング |

### 使用例

```bash
# イベント一覧の取得
curl https://your-api-id.execute-api.ap-northeast-1.amazonaws.com/events

# キーワード検索
curl https://your-api-id.execute-api.ap-northeast-1.amazonaws.com/events?keyword=Python

# イベント詳細の取得
curl https://your-api-id.execute-api.ap-northeast-1.amazonaws.com/events/123456/detail

# 東京都のイベントを取得
curl https://your-api-id.execute-api.ap-northeast-1.amazonaws.com/events/pref/tokyo
```

## プロジェクト構成

```
.
├── app/                    # アプリケーションコード
│   ├── main.py            # FastAPIアプリケーション
│   ├── requirements.txt   # Python依存関係
│   └── Dockerfile         # コンテナ定義
├── docs/                  # ワークショップドキュメント
│   └── README.md          # 詳細な手順書
├── template.yaml          # AWS SAMテンプレート
├── samconfig.toml         # SAMデプロイ設定
└── CLAUDE.md              # Claude Code用ガイド
```

## アーキテクチャ

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│   Client    │────▶│ API Gateway  │────▶│    Lambda       │
└─────────────┘     └──────────────┘     │  ┌───────────┐  │
                                          │  │ Web       │  │
                                          │  │ Adapter   │  │
                                          │  ├───────────┤  │
                                          │  │ FastAPI   │  │
                                          │  │ + Uvicorn │  │
                                          │  └───────────┘  │
                                          └─────────────────┘
                                                    │
                                                    ▼
                                          ┌─────────────────┐
                                          │ Connpass API    │
                                          │ (via proxy)     │
                                          └─────────────────┘
```

## 環境変数

アプリケーションは以下の環境変数を使用します：

- `API_KEY`: Connpass APIキー（AWS Systems Manager Parameter Storeから取得）

## セキュリティ考慮事項

- APIキーはParameter Storeで安全に管理
- 本番環境では適切なCORS設定が必要
- API Gatewayでのレート制限の設定を推奨

## トラブルシューティング

### デプロイエラー

```bash
# CloudFormationスタックの状態確認
aws cloudformation describe-stacks --stack-name sam-app

# Lambda関数のログ確認
sam logs -n EventFunction --stack-name sam-app --tail
```

### ローカル実行時のエラー

- ポート8080が使用中でないか確認
- 仮想環境が有効化されているか確認
- 依存関係が正しくインストールされているか確認

## 詳細なワークショップ手順

より詳細な手順については、[docs/README.md](docs/README.md)を参照してください。

## ライセンス

このプロジェクトはワークショップ用の教育目的で作成されています。

## 貢献

Issue や Pull Request は歓迎します。

## 参考リンク

- [AWS Lambda Web Adapter](https://github.com/awslabs/aws-lambda-web-adapter)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [AWS SAM Documentation](https://docs.aws.amazon.com/serverless-application-model/)
- [Connpass API](https://connpass.com/about/api/)