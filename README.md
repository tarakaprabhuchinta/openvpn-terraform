# OpenVPN on AWS with Terraform

[![Terraform Checks](https://github.com/tarakaprabhuchinta/openvpn-terraform/actions/workflows/terraform-checks.yml/badge.svg)](https://github.com/tarakaprabhuchinta/openvpn-terraform/actions/workflows/terraform-checks.yml) [![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://github.com/tarakaprabhuchinta/openvpn-terraform/blob/main/LICENSE)

This project provides a set of Terraform configurations to deploy an OpenVPN Access Server on AWS. It's designed to be a secure, reusable, and easy-to-use solution for creating your own VPN server.

## Features

- **Modular Design:** The project is divided into two main modules:
    - **VPC:** Sets up the networking infrastructure, including a VPC, public and private subnets, an internet gateway, route tables, and a security group.
    - **EC2:** Provisions an EC2 instance with the OpenVPN Access Server AMI, associates it with the VPC, and configures it with user data.
- **Secure by Default:** The project uses variables to handle sensitive information like passwords and SSH keys, avoiding hardcoded credentials.
- **Customizable:** You can easily customize the deployment by modifying the variables in the `terraform.tfvars` file.
- **Automated Setup:** The `user_data` script in the EC2 module automates the initial configuration of the OpenVPN server.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.12.2)
- [AWS account](https://aws.amazon.com/) and [configured credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- An SSH key pair

## Getting Started

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-username/openvpn-terraform.git
   cd openvpn-terraform
   ```

2. **Create a `terraform.tfvars` file:**

   Create a file named `terraform.tfvars` in the root of the project and add the following variables:

   ```hcl
   public_subnet_az   = "<your-aws-availability-zone>"
   private_subnet1_az = "<your-aws-availability-zone>"
   private_subnet2_az = "<your-aws-availability-zone>"
   ssh_public_key_path    = "/path/to/your/public_key.pub"
   ssh_key_name           = "<your-ssh-key-name>"
   openvpn_admin_user     = "<your-admin-username>"
   openvpn_admin_password = "<your-secure-password>"
   instance_type          = "t3.micro"
   ```

3. **Initialize Terraform:**

   ```bash
   terraform init
   ```

4. **Review the plan:**

   ```bash
   terraform plan
   ```

5. **Apply the configuration:**

   ```bash
   terraform apply
   ```

## Outputs

After the deployment is complete, Terraform will output the following information:

- `ip_address`: The public IP address of the EC2 instance. You can use this to access the OpenVPN admin UI and download client profiles.

## Post-Deployment Steps

### Enable IPv6

To activate IPv6 in the VPN tunnel, you will need to change the OpenVPN configuration settings after the EC2 instance is set up. For detailed instructions, please refer to the official OpenVPN documentation: [IPv6 Support in OpenVPN Access Server](https://openvpn.net/as-docs/ipv6-support.html#ipv6-in-the-vpn-tunnel).

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
