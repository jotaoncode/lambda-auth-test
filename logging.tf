resource "aws_iam_role_policy_attachment" "attach_policy_lambda_permissions_signup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.signup_lambda_role.name
}

resource "aws_iam_role_policy_attachment" "attach_policy_lambda_permissions_login" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.login_lambda_role.name
}
