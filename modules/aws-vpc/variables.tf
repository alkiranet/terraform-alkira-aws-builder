# variable "aws_vpc" {
#   description = "Controls if AWS Connectors are created"
#   type        = bool
#   default     = false
# }

variable "aws_vpc_data" {
  type = list(object({

    aws_account_id     = string
    region             = string
    create_network     = optional(bool, false)
    connect_network    = optional(bool, true)
    credential         = string
    cxp                = string
    group              = optional(string)
    name               = string
    ingress_cidrs      = optional(list(string), ["0.0.0.0/0"])
    network_cidr       = optional(string)
    network_id         = optional(string)
    segment            = string
    size               = optional(string, "SMALL")
    subnets            = optional(list(object({
      cidr             = string
      create_vm        = optional(bool, false)
      name             = string
      vm_type          = optional(string, "t2.nano")
    })))

  }))
    default = []
}

variable "public_key" {
  description  = "Path to public key used to connect to instances"
  type         = string
  sensitive    = true
  default      = "files/key.pub"
}