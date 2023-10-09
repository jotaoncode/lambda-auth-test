resource "aws_api_gateway_rest_api" "auth_api" {
  name        = "authentication"
  description = "Gateway Authentication"
}
