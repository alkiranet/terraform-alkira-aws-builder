module "aws_vpcs" {
  source  = "alkiranet/aws-builder/alkira"

  # Path to .yaml configuration files
  config_file = "./aws_vpcs.yaml"

}