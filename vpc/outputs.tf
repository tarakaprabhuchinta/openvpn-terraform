output "vpc_security_group_ids" {
  value = [aws_security_group.openvpn_instance_ipv4_sg.id]
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}