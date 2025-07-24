# hmddev-lambda-web-adapter-workshop

## 事前作業

```bash
USER_NAME=isseihamada
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

## AWS SAM インストール

1. **AWS SAM CLIインストーラーのダウンロード**
```bash
wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
```

2. **ファイルの解凍**
```bash
unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
```

3. **インストールの実行**
```bash
sudo ./sam-installation/install
```

   ※ sudo権限がない場合は、ユーザーディレクトリにインストール:
```bash
./sam-installation/install --install-dir ~/.local/aws-sam --bin-dir ~/.local/bin
```

4. **パスの設定** (ユーザーディレクトリにインストールした場合)
```bash
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

## ビルド & デプロイ

```bash
sam build
```

```bash
sam deploy --guided --image-repository $(ACCOUNT_ID).dkr.ecr.ap-northeast-1.amazonaws.com/connpassApi-$(USER_NAME)
```

# Lambda Web Adapter デプロイ手順

このドキュメントでは、AWS CLIとCloudFormationを使用してLambda Web Adapterアプリケーションをデプロイする手順を説明します。

## 前提条件

- AWS CLIがインストールされ、設定済みであること
- Dockerがインストールされ、実行中であること
- 適切なAWS権限（ECR、Lambda、API Gateway、CloudFormation）を持つIAMユーザーまたはロール

## デプロイ手順

### 1. 環境変数の設定

まず、デプロイに必要な環境変数を設定します：

```bash
export USER_NAME="jiroegami"
export REGION="ap-northeast-1"
export ECR_REPO_NAME=${USER_NAME}"-API"
export STACK_NAME=${USER_NAME}"-lambda-web-adapter-stack"
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

### 2. ECRリポジトリの作成

Dockerイメージを保存するためのECRリポジトリを作成します：

```bash
aws ecr create-repository --repository-name $ECR_REPO_NAME --region $REGION
```

### 3. ECRへのログイン

DockerクライアントをECRにログインさせます：

```bash
aws ecr get-login-password --region $REGION | \
    docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
```

### 4. Dockerイメージのビルド

アプリケーションのDockerイメージをビルドします：

```bash
docker build -t $ECR_REPO_NAME:latest ./app
cd ..
```

### 5. ECRへのイメージのプッシュ

ビルドしたイメージにタグを付けてECRにプッシュします：

```bash
# イメージURIを設定
export IMAGE_URI=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}:latest

# タグ付け
docker tag $ECR_REPO_NAME:latest $IMAGE_URI

# プッシュ
docker push $IMAGE_URI
```

### 6. CloudFormationスタックのデプロイ

CloudFormationテンプレートを使用してリソースをデプロイします：

```bash
aws cloudformation deploy \
    --template-file cloudformation-template.yaml \
    --stack-name $STACK_NAME \
    --parameter-overrides ImageUri=$IMAGE_URI \
    --capabilities CAPABILITY_IAM \
    --region $REGION
```

### 7. デプロイの確認

スタックのデプロイが完了したら、出力を確認します：

```bash
aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs' \
    --output table
```

### 8. APIエンドポイントの確認

API Gatewayのエンドポイントを取得します：

```bash
aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`ApiURL`].OutputValue' \
    --output text
```

## アプリケーションのテスト

デプロイが完了したら、以下のコマンドでAPIをテストできます：

```bash
API_URL=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`ApiURL`].OutputValue' \
    --output text)

curl $API_URL
```

## クリーンアップ

リソースを削除する場合は、以下のコマンドを実行します：

```bash
# CloudFormationスタックの削除
aws cloudformation delete-stack \
    --stack-name $STACK_NAME \
    --region $REGION

# スタックの削除完了を待つ
aws cloudformation wait stack-delete-complete \
    --stack-name $STACK_NAME \
    --region $REGION

# ECRリポジトリの削除（オプション）
aws ecr delete-repository \
    --repository-name $ECR_REPO_NAME \
    --region $REGION \
    --force
```

## トラブルシューティング

### Dockerソケットエラー（SageMaker環境）

SageMaker環境でDockerソケットエラーが発生する場合：

```bash
export DOCKER_HOST=unix:///docker/proxy.sock
```

### スタックのデプロイエラー

デプロイ中にエラーが発生した場合、以下のコマンドでイベントを確認できます：

```bash
aws cloudformation describe-stack-events \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]'
```

## 注意事項

- `CONNPASS_API_KEY`パラメータはSSM Parameter Storeに事前に設定する必要があります
- Lambda関数のメモリサイズやタイムアウト値は必要に応じて`cloudformation-template.yaml`で調整してください
- API Gatewayはデフォルトですべてのパスとメソッドを受け入れます（`$default`ルート）