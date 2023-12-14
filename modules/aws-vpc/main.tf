/*
aws_vpc
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
*/
resource "aws_vpc" "vpc" {
  for_each = {
    for o in var.aws_vpc_data : o.name => o
    if o.create_network == true
  }

  cidr_block = each.value.network_cidr

  tags = {
    Name = each.value.name
  }

}

data "aws_vpc" "vpc" {
  for_each = {
    for o in var.aws_vpc_data : o.name => o
    if o.create_network == false
  }

  id = each.value.network_id

}

/*
aws_subnet
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
*/
resource "aws_subnet" "subnet" {
  for_each = {
    for idx, subnet in flatten([
      for vpc in var.aws_vpc_data : [

        # If vpc.subnets is == null, use coalesce with empty list
        for subnet in coalesce(vpc.subnets, []) : {
          vpc_name        = vpc.name
          subnet_name     = subnet.name
          cidr_block      = subnet.cidr
          create_network  = vpc.create_network
        }
      ]
    ]) : "${subnet.vpc_name}-${subnet.subnet_name}" => {
      cidr_block = subnet.cidr_block
      vpc_id     = aws_vpc.vpc[subnet.vpc_name].id
      name       = subnet.subnet_name
    } if subnet.create_network
  }

  vpc_id     = each.value.vpc_id
  cidr_block = each.value.cidr_block

  tags = {
    Name = each.value.name
  }

}

locals {

  # List comprehension; Filter VPCs based on condition (subnet.create_vm)
  filter_vpcs = [
    for vpc in var.aws_vpc_data :
      vpc if anytrue([for subnet in coalesce(vpc.subnets, []) : subnet.create_vm])
  ]

  # Conditional expression; Any VPCs with subnets that get a vm
  create_vm   = length(local.filter_vpcs) > 0 ? local.filter_vpcs[0] : null

}

/*
aws_ami
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
Return id of Ubuntu 20.04 Server LTS on conditional basis
*/
data "aws_ami" "ubuntu" {
  count = local.create_vm != null ? 1 : 0

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = ["099720109477"]

}

/*
random_id
https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id
Generate random_id on conditional basis
*/
resource "random_id" "this" {
  count        = local.create_vm != null ? 1 : 0
  byte_length  = 8
}

/*
aws_key_pair
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
Provision aws_key_pair using random_id on conditional basis
*/
resource "aws_key_pair" "this" {
  count       = local.create_vm != null ? 1 : 0
  key_name    = random_id.this[0].hex
  public_key  = file(var.public_key)
}

/*
aws_instance
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
*/
resource "aws_instance" "instance" {
  for_each = {
    for idx, subnet in flatten([
      for vpc in var.aws_vpc_data : [
        for subnet in coalesce(vpc.subnets, []) : {
          vpc_name        = vpc.name
          subnet_name     = subnet.name
          subnet_id       = aws_subnet.subnet["${vpc.name}-${subnet.name}"].id
          create_vm       = subnet.create_vm
          vm_type         = subnet.vm_type
        }
      ]
    ]) : "${subnet.vpc_name}-${subnet.subnet_name}" => subnet if subnet.create_vm
  }

  ami            = data.aws_ami.ubuntu[0].id
  instance_type  = each.value.vm_type
  key_name       = length(aws_key_pair.this) > 0 ? aws_key_pair.this[0].key_name : null
  subnet_id      = each.value.subnet_id

  tags = {
    Name = "instance-${each.value.vpc_name}-${each.value.subnet_name}"
  }

}

locals {

  vpcs_with_vm = {
    for vpc in var.aws_vpc_data : vpc.name => vpc
    if anytrue([for subnet in coalesce(vpc.subnets, []) : subnet.create_vm])
  }

}

/*
aws_default_security_group
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group
*/
resource "aws_default_security_group" "default" {
  for_each = local.vpcs_with_vm

  vpc_id      = aws_vpc.vpc[each.key].id

  dynamic "ingress" {
    for_each = each.value.ingress_cidrs
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

locals {

  # filter 'segment' data
  filter_segments     = var.aws_vpc_data[*].segment

  # filter 'credential' data
  filter_credentials  = var.aws_vpc_data[*].credential

}

data "alkira_segment" "segment" {

  for_each = toset(local.filter_segments)

  name = each.value

}

data "alkira_credential" "credential" {

  for_each = toset(local.filter_credentials)

  name = each.value

}

/*
alkira_connector_aws_vpc
https://registry.terraform.io/providers/alkiranet/alkira/latest/docs/resources/connector_aws_vpc
*/
locals {

  filter_aws_vpcs = flatten([
    for c in var.aws_vpc_data : {
        aws_account_id   = c.aws_account_id
        region           = c.region
        create_network   = c.create_network
        connect_network  = c.connect_network
        credential       = lookup(data.alkira_credential.credential, c.credential, null).id
        cxp              = c.cxp
        group            = c.group
        name             = c.name
        # route_table_id   = try(aws_vpc.vpc[c.name].default_route_table_id, data.aws_vpc.vpc[c.name].default_route_table_id)
        route_table_id = c.create_network ? aws_vpc.vpc[c.name].main_route_table_id : data.aws_vpc.vpc[c.name].main_route_table_id
        segment          = lookup(data.alkira_segment.segment, c.segment, null).id
        size             = c.size
        network_cidr     = c.network_cidr
        network_id       = c.create_network ? lookup(aws_vpc.vpc, c.name, null).id : c.network_id
      }
  ])
}

resource "alkira_connector_aws_vpc" "connector" {

  for_each = {
    for o in local.filter_aws_vpcs : o.name => o
    if o.connect_network == true
  }

  aws_account_id  = each.value.aws_account_id
  aws_region      = each.value.region
  credential_id   = each.value.credential
  cxp             = each.value.cxp
  name            = each.value.name
  group           = each.value.group
  segment_id      = each.value.segment
  size            = each.value.size
  vpc_cidr        = [each.value.network_cidr]
  vpc_id          = each.value.network_id

  vpc_route_table {
    id       = each.value.route_table_id
    options  = "ADVERTISE_DEFAULT_ROUTE"
  }

  depends_on = [
    aws_vpc.vpc,
    aws_subnet.subnet
  ]

}