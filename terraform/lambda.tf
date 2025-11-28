resource "aws_security_group" "lambda" {
  name        = "adminer-lambda-sg"
  description = "Security group for the Adminer Lambda function"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_iam_role" "lambda_exec" {
  name = "adminer-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "adminer-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = aws_dynamodb_table.php_session_handler.arn
      }
    ]
  })
}

resource "random_password" "cipher_key" {
  length  = 64
  special = true
}

resource "aws_lambda_function" "adminer" {
  function_name    = "adminer-handler"
  role             = aws_iam_role.lambda_exec.arn
  timeout          = 30
  package_type     = "Image"
  image_uri        = "${aws_ecr_repository.adminer.repository_url}:latest"
  source_code_hash = trimprefix(data.aws_ecr_image.repo_image.id, "sha256:")

  vpc_config {
    subnet_ids         = data.aws_subnets.selected.ids
    security_group_ids = [aws_security_group.lambda.id]
  }
  environment {
    variables = {
      BREF_BINARY_RESPONSES = 1
      CIPHER_KEY            = sha512(random_password.cipher_key.result)
    }
  }
  tags = local.tags
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.adminer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.adminer.id}/*/*/adminer.php"
}
