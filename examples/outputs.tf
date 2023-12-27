output "aws_network_id" {
  value = try(module.aws_vpcs.aws_network_id, "")
}

output "aws_subnet_id" {
  value = try(module.aws_vpcs.aws_subnet_id, "")
}

output "alkira_connector_aws_id" {
  value = try(module.aws_vpcs.alkira_connector_aws_id, "")
}

output "alkira_connector_aws_implicit_group_id" {
  value = try(module.aws_vpcs.alkira_connector_aws_implicit_group_id, "")
}

output "aws_vm_private_ip" {
  value = try(module.aws_vpcs.aws_vm_private_ip, "")
}