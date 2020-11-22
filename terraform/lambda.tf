resource "aws_iam_role" "role" {
  name = "aws-static-site_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy" {
  role = aws_iam_role.role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "cloudfront:ListDistributions",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "cloudfront:CreateInvalidation",
      "Resource": "${aws_cloudfront_distribution.distribution.arn}"
    }
  ]
}
EOF
}

data "archive_file" "cache_invalidation" {
  type = "zip"
  source_dir = "../cache_invalidation"
  output_path = "../cache_invalidation.zip"
  excludes = [
    ".gitignore",
    ".nvmrc",
    "cache_invalidation.zip",
    "package-lock.json",
    "package.json"
  ]
}

resource "aws_lambda_function" "cache_invalidation" {
  function_name = "aws-static-site_cache-invalidation"
  source_code_hash = data.archive_file.cache_invalidation.output_base64sha256
  filename = "../cache_invalidation.zip"
  handler = "index.handler"

  role = aws_iam_role.role.arn

  runtime = "nodejs12.x"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cache_invalidation.arn
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.cache_invalidation.arn
    events = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:*"
    ]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
