# AWS Builder - Terraform Module
This module creates various resources in _Alkira_ and _AWS_ from **.yaml** files.

## Basic Usage
Define the path to your **.yaml** configuration file in the module.

```hcl
module "aws_vpcs" {
  source = "alkiranet/aws-builder/alkira"
  
  # path to config
  config_files = "./config/aws_vpcs.yaml"
  
}
```

### Configuration Example
The module will automatically create resources if they are present in the **.yaml** configuration with the proper _resource keys_ defined.

**aws_vpcs.yaml**
```yml
---
connector_aws:
  - name: 'vpc-east'
    description: 'AWS East Workloads'
    aws_account_id: '12345'
    region: 'us-east-2'
    credential: 'aws'
    cxp: 'US-EAST-2'
    group: 'cloud'
    segment: 'business'
    network_cidr: '10.5.0.0/16'
    network_id: 'vpc-012345678'
...
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.1 |
| <a name="requirement_alkira"></a> [alkira](#requirement\_alkira) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | ./modules/aws-vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_file"></a> [config\_file](#input\_config\_file) | Path to .yml files | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alkira_connector_aws_id"></a> [alkira\_connector\_aws\_id](#output\_alkira\_connector\_aws\_id) | ID of AWS connector |
| <a name="output_alkira_connector_aws_implicit_group_id"></a> [alkira\_connector\_aws\_implicit\_group\_id](#output\_alkira\_connector\_aws\_implicit\_group\_id) | Implicit group ID of AWS connector |
| <a name="output_aws_network_id"></a> [aws\_network\_id](#output\_aws\_network\_id) | ID of AWS VPC |
| <a name="output_aws_subnet_id"></a> [aws\_subnet\_id](#output\_aws\_subnet\_id) | ID of AWS subnet |
| <a name="output_aws_vm_private_ip"></a> [aws\_vm\_private\_ip](#output\_aws\_vm\_private\_ip) | Private IP of AWS virtual machine |
<!-- END_TF_DOCS -->