terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.45.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "MAIN-VPC"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "MAIN-IGW"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  tags = {
    "Name" = "MAIN-SUBNET"
  }
}

resource "aws_route" "main_r" {
  route_table_id         = aws_vpc.main.default_route_table_id
  gateway_id             = aws_internet_gateway.main_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "main_rta" {
  route_table_id = aws_vpc.main.default_route_table_id
  subnet_id      = aws_subnet.main_subnet.id
}

resource "aws_security_group" "main_sg" {
  vpc_id      = aws_vpc.main.id
  description = "The SG for our stuff"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server" {
  ami                    = "ami-09e67e426f25ce0d7"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.main_sg.id]
  subnet_id              = aws_subnet.main_subnet.id
  key_name               = "test-pair-1"
  user_data              = templatefile("${path.module}/server.tmpl", {})
}

resource "aws_eip" "server_eip" {
  vpc      = true
  instance = aws_instance.server.id
}

output "server_ip" {
  value = aws_eip.server_eip.public_ip
}

resource "aws_instance" "client" {
  ami                    = "ami-09e67e426f25ce0d7"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.main_sg.id]
  subnet_id              = aws_subnet.main_subnet.id
  key_name               = "test-pair-1"
  user_data              = templatefile("${path.module}/client.tmpl", { server_ip = aws_instance.server.private_ip })
}

resource "aws_eip" "client_eip" {
  vpc      = true
  instance = aws_instance.client.id
}

output "client_ip" {
  value = aws_eip.client_eip.public_ip
}
