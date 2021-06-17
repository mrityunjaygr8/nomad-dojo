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

resource "aws_instance" "main_instance" {
  ami                    = "ami-09e67e426f25ce0d7"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.main_sg.id]
  subnet_id              = aws_subnet.main_subnet.id
  #   private_ip             = "10.0.0.10"
  key_name = "test-pair-1"
}

resource "aws_eip" "main_eip" {
  vpc      = true
  instance = aws_instance.main_instance.id
}

output "eip_ip" {
  value = aws_eip.main_eip.public_ip
}
