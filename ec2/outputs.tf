output "ip_address" {
  description = "Public ip of EC2 instance"
  value       = aws_instance.openvpn_instance.public_ip
}