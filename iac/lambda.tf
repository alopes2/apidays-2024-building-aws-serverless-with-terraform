locals {
  function_name = "get-data"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "./lambda_init_code/index.js"
  output_path = "${local.function_name}_lambda_function_payload.zip"
}

data "aws_iam_policy_document" "assume_role" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${local.function_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policies.arn
}

resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.lambda.output_path
  function_name = "get-data"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
}

resource "aws_iam_policy" "lambda_policies" {
  name        = "lambda_policies_${aws_lambda_function.lambda.function_name}"
  path        = "/"
  description = "IAM policy for policies from a lambda"
  policy      = data.aws_iam_policy_document.lambda_policies.json
}

data "aws_iam_policy_document" "lambda_policies" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      # "dynamodb:GetItem"
      "dynamodb:Query"
    ]

    resources = [
      aws_dynamodb_table.movies.arn
    ]
  }
}
