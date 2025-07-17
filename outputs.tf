output "ip_address" {
  description = "URLs for OpenVPN admin module and config profile using the EC2 instance public IP"
  value       = "Admin module: https://${module.ec2.ip_address}/admin\nDownload config profile: https://${module.ec2.ip_address}"
}