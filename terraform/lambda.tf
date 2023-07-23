data "archive_file" "this" {
  source_file = "${path.module}/files/app.py"
  output_path = "app.zip"
  type        = "zip"
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:Scan",
    ]
    effect    = "Allow"
    resources = [module.dynamodb_table.dynamodb_table_arn]
  }
  statement {
    actions = ["s3:GetObject"]
    effect  = "Allow"
    resources = [
      module.s3.s3_bucket_arn,
      "${module.s3.s3_bucket_arn}/*",
    ]
  }
  statement {
    actions   = ["rekognition:DetectLabels"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.environment}_lambda_policy"
  policy = data.aws_iam_policy_document.lambda_policy.json

  tags = var.tags
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.environment}_lambda_execution_role"

  assume_role_policy = data.aws_iam_policy_document.lambda_execution_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "this" {
  filename      = "app.zip"
  description   = "Process new S3 objects and output metadata from Rekognition"
  function_name = var.environment
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.10"
  timeout       = 30

  environment {
    variables = {
      DYNAMODB_TABLE = module.dynamodb_table.dynamodb_table_id
    }
  }

  source_code_hash = data.archive_file.this.output_base64sha256

  tags = var.tags
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "this" {
  bucket = module.s3.s3_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
  }
}