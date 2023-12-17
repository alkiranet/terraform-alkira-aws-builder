output "aws_network_id" {
  description = "ID of AWS VPC"
  value = {
    for k, v in aws_vpc.vpc : k => v.id
  }
}

output "aws_subnet_id" {
  description = "ID of AWS subnet"
  value = {
    for k, v in aws_subnet.subnet : k => v.id
  }
}

output "alkira_connector_aws_id" {
  description = "ID of AWS connector"
  value = {
    for k, v in alkira_connector_aws_vpc.connector : k => v.id
  }
}

output "alkira_connector_aws_implicit_group_id" {
  description = "Implicit group ID of AWS connector"
  value = {
    for k, v in alkira_connector_aws_vpc.connector : k => v.implicit_group_id
  }
}

output "aws_vm_private_ip" {
  description = "Private IP of ec2 instance"
  value = {
    for k, v in aws_instance.instance : k => v.private_ip
  }
}