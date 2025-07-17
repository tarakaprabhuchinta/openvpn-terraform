data "aws_ami" "openvpn_ami_image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["OpenVPN Access Server Community Image-fe8020db-5343-4c43-9e65-5ed4a825c931"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["679593333241"]
}

resource "aws_instance" "openvpn_instance" {
  ami                         = data.aws_ami.openvpn_ami_image.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  subnet_id                   = var.subnet_id

  # This script configures the OpenVPN server on its first boot.
  user_data                   = <<EOF
# public_hostname=vpn.example.com The server's client-facing hostname (set as Route 53 A record)
admin_user=${var.openvpn_admin_user}
admin_pw=${var.openvpn_admin_password}
reroute_gw=1
reroute_dns=1
EOF
  user_data_replace_on_change = true
  tags                        = { Environment = var.environment, Name = "${var.prefix}-ec2" }

  lifecycle {
    precondition {
      condition     = can(regex("^ami-", data.aws_ami.openvpn_ami_image.id))
      error_message = "The image_id value must be a valid AMI id"
    }

    postcondition {
      condition     = self.public_ip != ""
      error_message = "EC2 instance must have a valid public ip"
    }
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}