<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.1 |
| <a name="requirement_alkira"></a> [alkira](#requirement\_alkira) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alkira"></a> [alkira](#provider\_alkira) | >= 1.1.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alkira_connector_aws_vpc.connector](https://registry.terraform.io/providers/alkiranet/alkira/latest/docs/resources/connector_aws_vpc) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_instance.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_subnet.subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [alkira_credential.credential](https://registry.terraform.io/providers/alkiranet/alkira/latest/docs/data-sources/credential) | data source |
| [alkira_segment.segment](https://registry.terraform.io/providers/alkiranet/alkira/latest/docs/data-sources/segment) | data source |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_vpc_data"></a> [aws\_vpc\_data](#input\_aws\_vpc\_data) | n/a | <pre>list(object({<br><br>    aws_account_id     = string<br>    region             = string<br>    create_network     = optional(bool, false)<br>    connect_network    = optional(bool, true)<br>    credential         = string<br>    cxp                = string<br>    group              = optional(string)<br>    name               = string<br>    ingress_cidrs      = optional(list(string), ["0.0.0.0/0"])<br>    network_cidr       = optional(string)<br>    network_id         = optional(string)<br>    segment            = string<br>    size               = optional(string, "SMALL")<br>    subnets            = optional(list(object({<br>      cidr             = string<br>      create_vm        = optional(bool, false)<br>      name             = string<br>      vm_type          = optional(string, "t2.nano")<br>    })))<br><br>  }))</pre> | `[]` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | Path to public key used to connect to instances | `string` | `"files/key.pub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alkira_connector_aws_id"></a> [alkira\_connector\_aws\_id](#output\_alkira\_connector\_aws\_id) | ID of AWS connector |
| <a name="output_alkira_connector_aws_implicit_group_id"></a> [alkira\_connector\_aws\_implicit\_group\_id](#output\_alkira\_connector\_aws\_implicit\_group\_id) | Implicit group ID of AWS connector |
| <a name="output_aws_network_id"></a> [aws\_network\_id](#output\_aws\_network\_id) | ID of AWS VPC |
| <a name="output_aws_subnet_id"></a> [aws\_subnet\_id](#output\_aws\_subnet\_id) | ID of AWS subnet |
| <a name="output_aws_vm_private_ip"></a> [aws\_vm\_private\_ip](#output\_aws\_vm\_private\_ip) | Private IP of ec2 instance |
<!-- END_TF_DOCS -->