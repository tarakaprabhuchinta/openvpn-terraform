locals {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/18"
  tags       = { Environment = var.environment, Name = "${var.prefix}-vpc" }

  lifecycle {
    postcondition {
      condition     = self.id != ""
      error_message = "Ensures vpc id is present after vpc is created"
    }
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = local.vpc_id
  cidr_block        = "10.0.0.0/24"
  availability_zone = var.public_subnet_az
  tags              = { Environment = var.environment, Name = "${var.prefix}-public-subnet" }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = local.vpc_id
  cidr_block        = "10.0.16.0/20"
  availability_zone = var.private_subnet1_az
  tags              = { Environment = var.environment, Name = "${var.prefix}-private-subnet1" }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = local.vpc_id
  cidr_block        = "10.0.32.0/20"
  availability_zone = var.private_subnet2_az
  tags              = { Environment = var.environment, Name = "${var.prefix}-private-subnet2" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = local.vpc_id
  tags   = { Environment = var.environment, Name = "${var.prefix}-internet-gateway" }
}

resource "aws_route_table" "public_route_table" {
  vpc_id     = local.vpc_id
  depends_on = [aws_subnet.public_subnet, aws_subnet.private_subnet1, aws_subnet.private_subnet2, aws_internet_gateway.igw]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block = "10.0.0.0/18"
    gateway_id = "local"
  }

  tags = { Environment = var.environment, Name = "${var.prefix}-public-route-table" }
}

resource "aws_route_table" "private_route_table" {
  vpc_id     = local.vpc_id
  depends_on = [aws_subnet.public_subnet, aws_subnet.private_subnet1, aws_subnet.private_subnet2, aws_internet_gateway.igw]
  route {
    cidr_block = "10.0.0.0/18"
    gateway_id = "local"
  }
  tags = { Environment = var.environment, Name = "${var.prefix}-private-route-table" }
}

// Setting private route table as main route table
resource "aws_main_route_table_association" "route_table_association" {
  vpc_id         = local.vpc_id
  route_table_id = aws_route_table.private_route_table.id
}

// Associating public route table with public subnet
resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

// Associating private route table with private subnet1
resource "aws_route_table_association" "private_subnet1_route_table_association" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}

// Associating private route table with private subnet2
resource "aws_route_table_association" "private_subnet2_route_table_association" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}

// This security group is configured based on the rules defined at: [https://openvpn.net/as-docs/aws-ec2.html#--launch-the-ami_body]
resource "aws_security_group" "openvpn_instance_ipv4_sg" {
  name        = "openvpn_ipv4_sg"
  description = "IPv4 security group to attach to OpenVPN EC2 instance"
  vpc_id      = local.vpc_id

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = var.protocols[ingress.key]
      cidr_blocks = var.ipv4_cidr_blocks[ingress.key]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Environment = var.environment, Name = "${var.prefix}-ipv4-security-group" }

}