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

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate"
  type        = list(string)

  validation {
    condition     = alltrue([for p in var.vpc_security_group_ids : can(regex("^sg-", p))])
    error_message = "Security group id must start with sg- format"
  }
}

variable "subnet_id" {
  description = "The subnet ID to launch the instance in"
  type        = string

  validation {
    condition     = can(regex("^subnet-", var.subnet_id))
    error_message = "Security group id must start with subnet- format"
  }
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key"

  validation {
    condition     = fileexists(var.ssh_public_key_path)
    error_message = "The provided SSH public key path does not exist."
  }
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the SSH key pair"

  validation {
    condition     = length(var.ssh_key_name) > 0
    error_message = "The SSH key name cannot be empty."
  }
}

variable "openvpn_admin_user" {
  type        = string
  description = "OpenVPN admin username"
  sensitive   = true

  validation {
    condition     = length(var.openvpn_admin_user) > 0
    error_message = "The OpenVPN admin username cannot be empty."
  }
}

variable "openvpn_admin_password" {
  type        = string
  description = "OpenVPN admin password"
  sensitive   = true

  validation {
    condition     = length(var.openvpn_admin_password) >= 8
    error_message = "The OpenVPN admin password must be at least 8 characters long."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z0-9]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "The instance type must be in a valid format (e.g., 't3.micro')."
  }
}
