# 入力側
resource "aws_s3_bucket" "input" {
  bucket = "example-aws-terraform-rust-input"
}

# 出力側
resource "aws_s3_bucket" "output" {
  bucket = "example-aws-terraform-rust-output"
}
