output "connector_aws_id" {
  value = try(module.aws_connectors.connector_aws_id, "")
}