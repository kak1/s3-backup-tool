# s3-backup-tool

## 利用方法
### 1. s3-backup-toolの設置
ホームディレクトリにs3-backup-toolを設置する
```
cd ~
git clone https://github.com/kak1/s3-backup-tool.git
```

### 2. 環境変数設定
バックアップIDとバックアップするファイルパスを指定。  
バックアップIDはサービスドメインやサービス名を推奨。  
バックアップIDはそのままIAMユーザ名として使い、s３のバックアップディレクトリ名にもなります。

下記は「xxx.com」サービスとしてホームディレクトリを全てバックアップする場合の環境変数設定
```
echo 'export S3_BACKUP_ID=xxx.com' >> ~/.bash_profile
echo 'export S3_BACKUP_PATH=$HOME' >> ~/.bash_profile
source ~/.bash_profile
```

### 3. mysqldumpコマンドのオプション設定
ユーザ名、パスワード（、ホスト名etc…）などを省略してmysqldumpコマンドを実行できるように、~/.my.cnfファイルを用意する。

~/.my.cnf
```
[mysqladmin]
user = root # ルート以外でも可ですが権限があるDBのみダンプ
password = xxxxxxxx
````

### 4. IAMユーザ追加
AWSマネジメントコンソールからユーザを追加する。  
https://console.aws.amazon.com/iam/home?region=ap-northeast-1#/users

1. ユーザー名にバックアップIDを入力。ただし、1つのユーザで複数サービスをバックアップする場合は、バックアップIDではなく会社名等でも良い。ただし、その場合「S3BackupTool」ポリシーを使えないので独自のポリシーを生成する必要がある。
1. アクセスの種類は「プログラムによるアクセス」を選択。
1. アクセス権限は「S3BackupTool」ポリシーをアタッチ。
1. ユーザ生成後、セキュリティ認証情報をダウンロード（アクセスキーIDとシークレットアクセスキーが必要）
1. ダインロードした認証情報csvのファイル名を「【ユーザ名】\_credentials.csv」に変更しておく

### 5. AWS CLIバージョン2のインストール
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install  # インストール
# ルート権限がない場合は下記でインストール
# ./aws/install -i ~/opt/aws-cli -b ~/bin
aws --version  # インストール確認
```
https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/install-cliv2-linux.html#cliv2-linux-install

### 6. AWSコマンドの基本設定
```
$ aws configure
AWS Access Key ID [None]: 【アクセスキーID】
AWS Secret Access Key [None]: 【シークレットアクセスキー】
Default region name [None]: ap-northeast-1
Default output format [None]: json
```
https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config

### 7. バックアップシェルの動作確認
下記を実行して、s3バックアップバケットのバックアップIDディレクトリにファイルバックアップとmysqlバックアップのgzファイルがコピーされていることを確認する。
```
sh ~/s3-backup-tool/backup.sh
```

### 8. バックアップcronの追加
下記をcrontabに追加
```
# バックアップ
0 3 * * * sh s3-backup-tool/backup.sh
```
