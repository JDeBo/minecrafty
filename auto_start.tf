locals {
  use_case = "minecraft"
}

resource "aws_lambda_function_url" "auto_starter" {
  function_name      = aws_lambda_function.auto_starter.function_name
  authorization_type = "NONE"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "StartEC2LambdaRole-${local.use_case}"

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
      "Sid": "AssumeRoleForLambda"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "ec2_lambda" {
  statement {
    sid       = "LambdaStartInstances"
    effect    = "Allow"
    actions   = ["ec2:StartInstances", "ec2:StopInstances"]
    resources = ["*"]  # Using * since spot instance ARN isn't directly available
  }
}

resource "aws_iam_policy" "ec2_lambda" {
  path        = "/"
  description = "LambdaStartEC2-${local.use_case}"
  policy      = data.aws_iam_policy_document.ec2_lambda.json
}

resource "aws_iam_role_policy_attachment" "ec2_lambda" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.ec2_lambda.arn
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "random_password" "lambda_password" {
  length           = 16
  special          = false
}

resource "aws_lambda_function" "auto_starter" {
  filename         = "${path.module}/auto_starter.zip"
  function_name    = "auto_start_ec2s_${local.use_case}"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.auto_starter.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      EC2_INSTANCES = jsonencode({ minecraft = aws_spot_instance_request.main.spot_instance_id })
      PSWD = random_password.lambda_password.result
    }
  }
  depends_on = [
    data.archive_file.auto_starter
  ]
}

data "archive_file" "auto_starter" {
  type        = "zip"
  source_file = "${path.module}/auto_starter/main.py"
  output_path = "${path.module}/auto_starter.zip"
}