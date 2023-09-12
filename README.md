# aws-terraform-rust

AWS 上で S3 から S3 へただオブジェクトを移動する Rust でかかれた Lambda を含むサンプルリポジトリです。
terraform を使ってインフラを管理しつつ Rust で書いた Lambda を cargo-lambda でデプロイしたい！という欲求に応えます。

## あそびかた

terraform パートと Lambda 本体パートの 2 つがあります。まずは terraform でインフラとダミーの Lambda を作り、その後 Lambda のデプロイへ進んでください。

### terraform

s3.tf にある 2 つのバケットの名前 (最初は `example-aws-terraform-rust-{input,output}` になっています) をそれぞれ適当な名前に変更してください。というのも私はこの名前で作っているのですが、S3 はユーザーに関係なくグローバルに一意な名前でないとエラーになってしまうので、衝突してエラーになってしまうと思います。

インフラの中身を確認したら、terraform でデプロイします。次のコマンドの `{your-aws-profile}` を使いたいプロファイルに変えて実行してください。

```
TF_VAR_aws_profile={your-aws-profile} terraform apply
```

### Rust Lambda

actual_lambda にある Cargo プロジェクトが実際に Rust で書かれた Lambda 本体です。

cargo-lambda を使うのですが、cargo-lambda が公式で Docker イメージ (ghcr.io/cargo-lambda/cargo-lambda) を提供してくれています。これを使ってビルド・デプロイするコマンドを Makefile に書いておきました。詳細は `actual_lambda/Makefile` を見てください。

```
cd actual_lambda

# ビルド
make build

# デプロイ
AWS_PROFILE={your-profile-name} make deploy
```

## 実際の Rust で書かれた Lambda

Lambda の本体は `actual_lambda` に置いてある Cargo プロジェクトです。シンプルに S3 から拾って S3 に置くだけのコードです。
