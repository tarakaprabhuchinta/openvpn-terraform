variable "environment" {
  type        = string
  description = "Current Terraform environment"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "The environment must be either dev or prod"
  }
}

variable "prefix" {
  type        = string
  description = "Prefix that needed to be added in tags for each resource"

  validation {
    condition     = can(regex("(dev|prod)", var.prefix))
    error_message = "Prefix needs to have either dev or prod words in prefix"
  }
}

variable "public_subnet_az" {
  type        = string
  description = "Availability zone of public subnet"

  validation {
    condition     = can(regex("(east|west|south|north|central)", var.public_subnet_az))
    error_message = "The value must contain one of the words: east, west, south, north, or central."
  }
}

variable "private_subnet1_az" {
  type        = string
  description = "Availability zone of first private subnet"

  validation {
    condition     = can(regex("(east|west|south|north|central)", var.private_subnet1_az))
    error_message = "The value must contain one of the words: east, west, south, north, or central."
  }
}

variable "private_subnet2_az" {
  type        = string
  description = "Availability zone of second private subnet"

  validation {
    condition     = can(regex("(east|west|south|north|central)", var.private_subnet2_az))
    error_message = "The value must contain one of the words: east, west, south, north, or central."
  }
}

// The following variables are set according to the guidelines at: [https://openvpn.net/as-docs/aws-ec2.html#--launch-the-ami_body]
// Adjust these values as needed for your setup

variable "protocols" {
  type    = list(string)
  default = ["tcp", "tcp", "tcp", "tcp", "udp"]

  validation {
    condition     = alltrue([for p in var.protocols : contains(["tcp", "udp"], p)])
    error_message = "Protocols must be either 'tcp' or 'udp'."
  }
}

variable "ports" {
  type    = list(string)
  default = ["22", "943", "945", "443", "1194"]

  validation {
    condition = alltrue([
      for p in var.ports :
      can(regex("^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$", p))
    ])
    error_message = "Each port must be a string representing a valid number between 1 and 65535."
  }
}

// List of CIDR block identifiers corresponding to the ports above for inbound traffic configuration in ipv4 format
variable "ipv4_cidr_blocks" {
  type    = list(list(string))
  default = [["0.0.0.0/0"], ["0.0.0.0/0"], ["0.0.0.0/0"], ["0.0.0.0/0"], ["0.0.0.0/0"]]

  validation {
    condition = alltrue([
      for cidr_list in var.ipv4_cidr_blocks :
      alltrue([
        for cidr in cidr_list :
        can(cidrnetmask(cidr))
      ])
    ])
    error_message = "Each value in ipv4_cidr_blocks must be a valid IPv4 CIDR block"
  }
}