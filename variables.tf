variable "public_subnet_az" {
  type        = string
  description = "Availability zone of public subnet"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9][a-z]$", var.public_subnet_az))
    error_message = "The availability zone must be in a valid format (e.g., 'us-east-1a')."
  }
}

variable "private_subnet1_az" {
  type        = string
  description = "Availability zone of first private subnet"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9][a-z]$", var.private_subnet1_az))
    error_message = "The availability zone must be in a valid format (e.g., 'us-east-1b')."
  }
}

variable "private_subnet2_az" {
  type        = string
  description = "Availability zone of second private subnet"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9][a-z]$", var.private_subnet2_az))
    error_message = "The availability zone must be in a valid format (e.g., 'us-east-1c')."
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
