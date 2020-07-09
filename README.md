# Choices-AWS-Lambda-RDS
Amazon RDS のデータを [Questetra BPM Suite](https://questetra.com/) の「検索セレクトボックス」の外部マスタとして使用するための 
AWS の [Terraform](https://www.terraform.io/) テンプレートです。

## 注意点
RDS Proxy は現時点では Terraform に対応していないため、RDS Proxy を使用する場合は別途 AWS コンソールで追加する必要があります
（本テンプレートでは RDS Proxy を経由せずに直接 RDS に接続します）。

## 事前準備
以下のものが必要です。
* [Terraform クライアント](https://www.terraform.io/downloads.html)
* [AWS クライアント](https://aws.amazon.com/cli/)
* [npm](https://www.npmjs.com/)

AWS の認証情報は `aws configure` コマンドで設定するか、provider.tf ファイル内の provider ブロック内に記載します（[参考](https://www.terraform.io/docs/providers/aws/index.html#static-credentials)）。

lambda-src ディレクトリ内で `npm install` を実行し、必要なパッケージをインストールしておきます（node_modulesディレクトリが作成されます）。

## 使い方
同じディレクトリに .tfvars ファイル（たとえば vars.tfvars）を作成し、 variables.tf で定義されている変数の値を指定します。

vars.tfvars の例
```
aws_region = "us-east-2"
vpc_cidr_block = "10.0.0.0/16"
my_ip = "0.0.0.0/0" // データベースへの接続を許可する IP アドレス（この例では全てのIPアドレスを許可）
db_password = "password1234"
```

ディレクトリ内で `terraform init` を実行してワークスペースとして初期化し、
`terraform plan -var-file=vars.tfvars` で変更内容を確認します。
変更内容に問題がなければ、`tarraform apply` で変更を実行します。

## データ形式
データベースには `value` と `display` の２つの列からなるテーブルを作成します。

テーブル作成例
```
create database sample_db;
use sample_db;
CREATE TABLE `nations` (
  `value` VARCHAR(10) NOT NULL PRIMARY KEY,
  `display` VARCHAR(100) NOT NULL
) DEFAULT CHARSET=utf8;
INSERT INTO nations (value, display)
    VALUES
      ("JP", "日本"),
      ("US", "アメリカ"),
      ("UK", "イギリス"),
      ("AU", "オーストラリア");
```