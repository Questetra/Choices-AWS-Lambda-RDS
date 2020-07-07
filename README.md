# Choices-AWS-Lambda-RDS
Amazon RDS のデータを [Questetra BPM Suite](https://questetra.com/) の「検索セレクトボックス」の外部マスタとして使用するための 
AWS の [Terraform](https://www.terraform.io/) テンプレートです（作成中）。

## 注意点
RDS Proxy は現時点では Terraform に対応していないため、別途 AWS コンソールで追加する必要があります。

## 事前準備
以下のものが必要です。
* [Terraform クライアント](https://www.terraform.io/downloads.html)
* [AWS クライアント](https://aws.amazon.com/cli/)

AWS の認証情報は `aws configure` コマンドで設定するか、provider.tf ファイル内の provider ブロック内に記載します（[参考](https://www.terraform.io/docs/providers/aws/index.html#static-credentials)）。

## 使い方
同じディレクトリに .tfvars ファイル（たとえば vars.tfvars）を作成し、 variables.tf で定義されている変数の値を指定します。

vars.tfvars の例（一部）
```
# used in provider.tf
aws_region = "us-east-2"

# used in network.tf
vpc_cidr_block = "10.0.0.0/16"
my_ip = "0.0.0.0/0" // データベースへの接続を許可する IP アドレス

# used in database.tf
db_cluster_identifier = "sample-database-1"
db_username = "admin"
db_password = "password1234"
db_instance_identifier = "sample-database-1-instance-1"
```

ディレクトリ内で `terraform init` を実行してワークスペースとして初期化し、
`terraform plan -var-file=vars.tfvars` で変更内容を確認します。
変更内容に問題がなければ、`tarraform apply` で変更を実行します。

