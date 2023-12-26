# AWS Builder - Terraform Module
This module creates various resources in _Alkira_ and _AWS_ from **.yaml** files.

## Basic Usage
Reference [alkiranet/aws-builder/alkira](https://registry.terraform.io/modules/alkiranet/aws-builder/alkira/latest) as the _source_ and define the path to the **.yaml** configuration file.

```hcl
module "aws_vpcs" {
  source = "alkiranet/aws-builder/alkira"
  
  # path to config
  config_files = "./aws_vpcs.yaml"
  
}
```

### Basic Usage
This module will automatically create resources if they are present in the **.yaml** configuration with the proper _resource keys_ defined. You can find a detailed example project and files [here.](https://github.com/alkiranet/terraform-alkira-aws-builder/tree/main/examples)

**aws_vpcs.yaml**
```yml
---
aws_vpc:

  # Connect VPC that already exists to Alkira
  - name: 'vpc-east-dev'
    aws_account_id: '12345678'
    region: 'us-east-2'
    credential: 'aws'
    cxp: 'us-east-2'
    group: 'nonprod'
    segment: 'business'
    network_cidr: '10.5.0.0/16'
    network_id: 'vpc-012345678' # replace with appropriate id

  # Provision new VPC and connect to Alkira
  - name: 'vpc-east-qa'
    billing_tag: 'app-team-a'
    create_network: true # This parameter should be set to 'true'
    aws_account_id: '12345678'
    region: 'us-east-2'
    credential: 'aws'
    cxp: 'us-east-2'
    group: 'nonprod'
    segment: 'business'
    network_cidr: '10.6.0.0/16'
    subnets:
      - name: 'subnet1-qa'
        cidr: '10.6.1.0/24'
        create_vm: true # Optional attribute to provision instances on a per subnet basis

      - name: 'subnet2-qa'
        cidr: '10.6.2.0/24'
        create_vm: true
        zone: 'us-east-2a' # Optionally specify availability-zone
        vm_type: 't2.large' # Optionally specify instance type (default is t2.nano)

  # Provision new VPC but don't connect to Alkira
  - name: 'vpc-east-sbox'
    create_network: true # This parameter should be set to 'true'
    connect_network: false # This parameter should be set to 'false'
    aws_account_id: '12345678'
    region: 'us-east-2'
    network_cidr: '10.7.0.0/16'
    subnets:
      - name: 'subnet1-sbox'
        cidr: '10.7.1.0/24'
        create_vm: true # Optional attribute to provision instances on a per subnet basis

      - name: 'subnet2-sbox'
        cidr: '10.7.2.0/24'
    tags: # Optional AWS tags to add to resources
      email: 'me@email.com'
      env: 'sbox'
...
```

:warning: This project is used in tandem with other projects like [azure-builder](https://registry.terraform.io/modules/alkiranet/azure-builder/alkira/latest) and [gcp-builder](https://registry.terraform.io/modules/alkiranet/gcp-builder/alkira/latest) to test and demonstrate a complete _end-to-end_ Multi-Cloud network. Since parameters like _vpc_id_ and _vpc_cidr_ exist in each cloud provider, just with different names, these modules use _network_id_ and _network_cidr_ for commonality.

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