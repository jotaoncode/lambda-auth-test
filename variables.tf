variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "us-east-1"
}

variable "encrypt_code" {
  description = "To encrypt passwords"

  type    = string
  default = "SuperPassword"
}

variable "sign_session" {
  description = "To sign tokens of sessions"

  type    = string
  default = "MrBean"
}
