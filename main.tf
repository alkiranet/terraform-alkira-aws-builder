locals {

  # parse .yaml configuration
  config_file_content = fileexists(var.config_file) ? file(var.config_file) : "NoConfigurationFound: true"
  config              = yamldecode(local.config_file_content)

  # does 'aws_vpc' key exist in the configuration?
  aws_vpc_exists      = contains(keys(local.config), "aws_vpc")
}

module "aws_vpc" {
  source = "./modules/aws-vpc"

  # if 'aws_vpc' exists, create resources
  count = local.aws_vpc_exists ? 1 : 0

  # pass configuration
  aws_vpc_data = local.config["aws_vpc"]

}