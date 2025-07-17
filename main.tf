locals {
  environment = terraform.workspace
  prefix      = "openvpn-${local.environment}"
}

module "vpc" {
  source             = "./vpc"
  environment        = local.environment
  prefix             = local.prefix
  public_subnet_az   = var.public_subnet_az
  private_subnet1_az = var.private_subnet1_az
  private_subnet2_az = var.private_subnet2_az
}

module "ec2" {
  source = "./ec2"
  # Ensures the EC2 instance is created only after all the resources in vpc module are provisioned.
  depends_on             = [module.vpc]
  environment            = local.environment
  prefix                 = local.prefix
  vpc_security_group_ids = module.vpc.vpc_security_group_ids
  subnet_id              = module.vpc.public_subnet_id
  ssh_public_key_path    = var.ssh_public_key_path
  ssh_key_name           = var.ssh_key_name
  openvpn_admin_user     = var.openvpn_admin_user
  openvpn_admin_password = var.openvpn_admin_password
  instance_type          = var.instance_type
}