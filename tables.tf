
resource "aws_dynamodb_table" "users_table" {
  name           = "users-table"
  hash_key       = "name"
  read_capacity = 1
  write_capacity = 1
  attribute {
    name = "name"
    type = "S"
  }
}

resource "aws_dynamodb_table" "sessions_table" {
  name           = "sessions-table"
  hash_key       = "name"
  read_capacity = 1
  write_capacity = 1
  attribute {
    name = "name"
    type = "S"
  }
}

data "aws_iam_policy_document" "lambda_dynamodb_readonly_policy_document" {
  statement {
    actions   = ["dynamodb:GetItem"]
    effect    = "Allow"
    resources = [aws_dynamodb_table.users_table.arn]
  }
}

data "aws_iam_policy_document" "lambda_dynamodb_readwrite_policy_document" {
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem"]
    effect    = "Allow"
    resources = [aws_dynamodb_table.users_table.arn]
  }
}

data "aws_iam_policy_document" "lambda_dynamodb_readwrite_sessions_policy_document" {
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem"]
    effect    = "Allow"
    resources = [aws_dynamodb_table.sessions_table.arn]
  }
}

resource "aws_iam_policy" "readonly_dynamodb_policy" {
  name        = "readonly-dynamodb-policy"
  description = "Read only Policy for DynamoDB access"
  policy      = data.aws_iam_policy_document.lambda_dynamodb_readonly_policy_document.json
}

resource "aws_iam_policy" "readwrite_sessions_dynamodb_policy" {
  name        = "sessions-dynamodb-policy"
  description = "ReadWrite Policy for Sessions DynamoDB access"
  policy      = data.aws_iam_policy_document.lambda_dynamodb_readwrite_sessions_policy_document.json
}

resource "aws_iam_policy" "readwrite_dynamodb_policy" {
  name        = "readwrite-dynamodb-policy"
  description = "ReadWrite Policy for Users DynamoDB access"
  policy      = data.aws_iam_policy_document.lambda_dynamodb_readwrite_policy_document.json
}

resource "aws_iam_role_policy_attachment" "attach_policy_dynamo_readwrite_lambda" {
  policy_arn = aws_iam_policy.readwrite_dynamodb_policy.arn
  role       = aws_iam_role.signup_lambda_role.name
}
