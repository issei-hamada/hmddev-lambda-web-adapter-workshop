# hmddev-lambda-web-adapter-workshop

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