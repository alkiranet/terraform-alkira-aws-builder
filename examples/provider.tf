provider "alkira" {
  portal   = var.alk_portal
  api_key  = var.alk_api_key
}

provider "aws" {
  region     = "us-east-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}