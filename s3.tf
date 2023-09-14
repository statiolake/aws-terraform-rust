# 入力側
resource "aws_s3_bucket" "input" {
  bucket = "example-aws-terraform-rust-input"
}

# 出力側
resource "aws_s3_bucket" "output" {
  bucket = "example-aws-terraform-rust-output"
}

# 入力側の S3 の Put イベントで Lambda を呼び出す
resource "aws_s3_bucket_notification" "put_notification" {
  bucket = aws_s3_bucket.input.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:Put"]
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input.arn
}
