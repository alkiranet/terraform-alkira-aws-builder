variable "aws_vpc_data" {
  type = list(object({
    aws_account_id     = string
    billing_tag        = optional(string)
    connect_network    = optional(bool, true)
    create_network     = optional(bool, false)
    credential         = string
    cxp                = string
    group              = optional(string)
    ingress_cidrs      = optional(list(string), ["0.0.0.0/0"])
    name               = string
    network_cidr       = optional(string)
    network_id         = optional(string)
    region             = string
    segment            = string
    size               = optional(string, "SMALL")
    subnets            = optional(list(object({
      cidr             = string
      create_vm        = optional(bool, false)
      name             = string
      vm_type          = optional(string, "t2.nano")
      zone             = optional(string)
    })))
    tags               = optional(map(string))
  }))
  default = []
}

variable "public_key" {
  description  = "Path to public key used to connect to instances"
  type         = string
  sensitive    = true
  default      = "files/key.pub"
}