data "archive_file" "login_payload" {
  type        = "zip"
  source_file = "dist/login.js"
  output_path = "login_function_payload.zip"
}

resource "aws_lambda_function" "login_lambda" {
  filename      = "login_function_payload.zip"
  function_name = "login"
  role          = aws_iam_role.login_lambda_role.arn
  handler = "login.handler"

  source_code_hash = data.archive_file.login_payload.output_base64sha256

  runtime = "nodejs18.x"

  environment {
    variables = {
      DYNAMODB_USERS_TABLE_NAME = aws_dynamodb_table.users_table.name,
      DYNAMODB_SESSIONS_TABLE_NAME = aws_dynamodb_table.sessions_table.name,
      REGION = var.aws_region
      ENCRYPT_CODE = var.encrypt_code,
      SIGN_SESSION = var.sign_session
    }
  }
}

resource "aws_iam_role" "login_lambda_role" {
  name = "login-lambda-role"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_dynamo_read_lambda" {
  policy_arn = aws_iam_policy.readonly_dynamodb_policy.arn
  role       = aws_iam_role.login_lambda_role.name
}

resource "aws_iam_role_policy_attachment" "attach_policy_dynamo_readwrite_sessions_lambda" {
  policy_arn = aws_iam_policy.readwrite_sessions_dynamodb_policy.arn
  role       = aws_iam_role.login_lambda_role.name
}

resource "aws_api_gateway_resource" "login_resource" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  parent_id   = aws_api_gateway_rest_api.auth_api.root_resource_id
  path_part   = "login"
}

resource "aws_api_gateway_method" "login_method" {
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  resource_id   = aws_api_gateway_resource.login_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "gateway_login_integration" {
  depends_on      = [aws_lambda_function.login_lambda]
  rest_api_id             = aws_api_gateway_rest_api.auth_api.id
  resource_id             = aws_api_gateway_resource.login_resource.id
  http_method             = aws_api_gateway_method.login_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.login_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "login_gateway_deploy" {
  depends_on      = [aws_api_gateway_integration.gateway_login_integration]
  rest_api_id      = aws_api_gateway_rest_api.auth_api.id
  stage_name = "dev"
}

resource "aws_lambda_permission" "login_lambda_permission_to_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.login_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.auth_api.execution_arn}/*/*"
}

output "login_lambda_arn" {
  value = aws_lambda_function.login_lambda.arn
}

output "login_api_gateway_url" {
  value = aws_api_gateway_deployment.login_gateway_deploy.invoke_url
}