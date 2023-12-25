provider "alkira" {
  portal   = var.alk_portal
  api_key  = var.alk_api_key
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}