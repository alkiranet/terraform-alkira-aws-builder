output "aws_network_id" {
  description = "ID of AWS VPC"
  value = try(module.aws_vpc.*.aws_network_id, "")
}

output "aws_subnet_id" {
  description = "ID of AWS subnet"
  value = try(module.aws_vpc.*.aws_subnet_id, "")
}

output "alkira_connector_aws_id" {
  description = "ID of AWS connector"
  value = try(module.aws_vpc.*.alkira_connector_aws_id, "")
}

output "alkira_connector_aws_implicit_group_id" {
  description = "Implicit group ID of AWS connector"
  value = try(module.aws_vpc.*.alkira_connector_aws_implicit_group_id, "")
}

output "aws_vm_private_ip" {
  description = "Private IP of AWS virtual machine"
  value = try(module.aws_vpc.*.aws_vm_private_ip, "")
}