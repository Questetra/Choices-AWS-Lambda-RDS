# Choices-AWS-Lambda-RDS
Amazon RDS のデータを [Questetra BPM Suite](https://questetra.com/) の「検索セレクトボックス」の外部マスタとして使用するための 
AWS の [Terraform](https://www.terraform.io/) テンプレートです（作成中）。

## 使い方
同じディレクトリに .tfvars ファイル（たとえば vars.tfvars）を作成し、 variables.tf で定義されている変数の値を指定します。

vars.tfvars の例
```
# used in provider.tf
aws_region = "us-east-2"

# used in network.tf
vpc_cidr_block = "10.0.0.0/16"
my_ip = "0.0.0.0/0" // データベースへの接続を許可する IP アドレス

# used in database.tf
db_cluster_identifier = "sample-database-1"
db_username = "admin"
db_instance_identifier = "sample-database-1-instance-1"
```

ディレクトリ内で `terraform init` を実行してワークスペースとして初期化し、
`terraform plan -var-file=vars.tfvars` で変更内容を確認します。
変更内容に問題がなければ、`tarraform apply` で変更を実行します。

