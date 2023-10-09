data "archive_file" "signup_payload" {
  type        = "zip"
  source_file = "dist/signup.js"
  output_path = "signup_function_payload.zip"
}

resource "aws_lambda_function" "signup_lambda" {
  filename      = "signup_function_payload.zip"
  function_name = "signup"
  role          = aws_iam_role.signup_lambda_role.arn
  handler = "signup.handler"

  source_code_hash = data.archive_file.signup_payload.output_base64sha256

  runtime = "nodejs18.x"

  environment {
    variables = {
      DYNAMODB_USERS_TABLE_NAME = aws_dynamodb_table.users_table.name,
      REGION = var.aws_region,
      ENCRYPT_CODE = var.encrypt_code,
      SIGN_SESSION = var.sign_session
    }
  }
}

resource "aws_iam_role" "signup_lambda_role" {
  name = "signup-lambda-role"

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

resource "aws_api_gateway_resource" "signup_resource" {
  rest_api_id = aws_api_gateway_rest_api.auth_api.id
  parent_id   = aws_api_gateway_rest_api.auth_api.root_resource_id
  path_part   = "signup"
}

resource "aws_api_gateway_method" "signup_method" {
  rest_api_id   = aws_api_gateway_rest_api.auth_api.id
  resource_id   = aws_api_gateway_resource.signup_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "gateway_signup_integration" {
  rest_api_id             = aws_api_gateway_rest_api.auth_api.id
  resource_id             = aws_api_gateway_resource.signup_resource.id
  http_method             = aws_api_gateway_method.signup_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.signup_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "signup_gateway_deploy" {
  depends_on      = [aws_api_gateway_integration.gateway_signup_integration]
  rest_api_id      = aws_api_gateway_rest_api.auth_api.id
  stage_name = "dev"
}

resource "aws_lambda_permission" "signup_lambda_permission_to_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signup_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.auth_api.execution_arn}/*/*"
}

output "signup_lambda_arn" {
  value = aws_lambda_function.signup_lambda.arn
}

output "signup_api_gateway_url" {
  value = aws_api_gateway_deployment.signup_gateway_deploy.invoke_url
}
