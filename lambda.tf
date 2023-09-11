resource "aws_iam_role" "lambda_role" {
  name               = "example-aws-terraform-rust-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

# AssumeRole 用のポリシー
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Lambda に与える権限を設定するポリシー
resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = "example-aws-terraform-rust-lambda-role-policy"
  role   = aws_iam_role.lambda_role.name
  policy = data.aws_iam_policy_document.lambda_policy.json
}

data "aws_iam_policy" "lambda_basic_execution_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_policy" {
  source_policy_documents = [data.aws_iam_policy.lambda_basic_execution_policy.policy]

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.input.arn, aws_s3_bucket.output.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.input.arn}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.output.arn}/*"]
  }
}

resource "aws_lambda_function" "lambda" {
  function_name    = "example-aws-terraform-rust"
  handler          = "bootstrap"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "provided.al2"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  lifecycle {
    ignore_changes = [source_code_hash]
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "dummy_lambda"
  output_path = "archive/dummy_lambda.zip"
}
