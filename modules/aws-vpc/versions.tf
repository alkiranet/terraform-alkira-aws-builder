terraform {
  required_version = ">= 1.6.1"

  required_providers {

    alkira = {
      source  = "alkiranet/alkira"
      version = ">= 1.1.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

  }
}