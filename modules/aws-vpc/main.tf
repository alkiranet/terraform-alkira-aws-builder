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

  tags = merge(
    { "Name" = each.value.name },
    each.value.tags
  )

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
          availability_zone = subnet.zone
          cidr_block        = subnet.cidr
          create_network    = vpc.create_network
          subnet_name       = subnet.name
          vpc_name          = vpc.name
          vpc_tags          = vpc.tags
        }
      ]
    ]) : "${subnet.vpc_name}-${subnet.subnet_name}" => {
      availability_zone = subnet.availability_zone
      cidr_block        = subnet.cidr_block
      name              = subnet.subnet_name
      vpc_id            = aws_vpc.vpc[subnet.vpc_name].id
      vpc_tags          = subnet.vpc_tags
    } if subnet.create_network
  }

  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block
  vpc_id            = each.value.vpc_id

  tags = merge(
    { "Name" = each.value.name },
    each.value.vpc_tags
  )

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
          create_vm       = subnet.create_vm
          name            = format("instance-%s", subnet.name)
          subnet_name     = subnet.name
          subnet_id       = aws_subnet.subnet["${vpc.name}-${subnet.name}"].id
          vpc_name        = vpc.name
          vpc_tags        = vpc.tags
          vm_type         = subnet.vm_type
        }
      ]
    ]) : "${subnet.vpc_name}-${subnet.subnet_name}" => subnet if subnet.create_vm
  }

  ami            = data.aws_ami.ubuntu[0].id
  instance_type  = each.value.vm_type
  key_name       = length(aws_key_pair.this) > 0 ? aws_key_pair.this[0].key_name : null
  subnet_id      = each.value.subnet_id

  tags = merge(
    { "Name" = each.value.name },
    each.value.vpc_tags
  )

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

  tags = merge(
    { "Name" = each.value.name },
    aws_vpc.vpc[each.value.name].tags
  )

}

locals {

  # filter 'billing_tag' data
  filter_billing_tags = [for vpc in var.aws_vpc_data : vpc.billing_tag if vpc.billing_tag != null]

  # filter 'credential' data
  filter_credentials   = var.aws_vpc_data[*].credential

  # filter 'segment' data
  filter_segments      = var.aws_vpc_data[*].segment

}

data "alkira_billing_tag" "billing_tag" {

  for_each = toset(local.filter_billing_tags)

  name = each.value

}

data "alkira_credential" "credential" {

  for_each = toset(local.filter_credentials)

  name = each.value

}

data "alkira_segment" "segment" {

  for_each = toset(local.filter_segments)

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
        billing_tag      = c.billing_tag != null ? data.alkira_billing_tag.billing_tag[c.billing_tag].id : null
        connect_network  = c.connect_network
        create_network   = c.create_network
        credential       = lookup(data.alkira_credential.credential, c.credential, null).id
        cxp              = c.cxp
        group            = c.group
        name             = c.name
        network_cidr     = c.network_cidr
        network_id       = c.create_network ? lookup(aws_vpc.vpc, c.name, null).id : c.network_id
        region           = c.region
        route_table_id   = c.create_network ? aws_vpc.vpc[c.name].main_route_table_id : data.aws_vpc.vpc[c.name].main_route_table_id
        segment          = lookup(data.alkira_segment.segment, c.segment, null).id
        size             = c.size
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
  billing_tag_ids = each.value.billing_tag != null ? [each.value.billing_tag] : []
  credential_id   = each.value.credential
  cxp             = each.value.cxp
  group           = each.value.group
  name            = each.value.name
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