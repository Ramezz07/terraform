terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}


resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "my-pub-sn-1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "my-pub-sn-1"
  }
}

resource "aws_subnet" "my-pub-sn-2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "my-pub-sn-2"
  }
}

resource "aws_internet_gateway" "my-ig" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-ig"
  }
}

resource "aws_route_table" "my-pub-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-ig.id
  }
  tags = {
    Name = "my-pub-rt"
  }
}

resource "aws_route_table_association" "my-rb-ass-1" {
  subnet_id      = aws_subnet.my-pub-sn-1.id
  route_table_id = aws_route_table.my-pub-rt.id
}

resource "aws_route_table_association" "my-rb-ass-2" {
  subnet_id      = aws_subnet.my-pub-sn-2.id
  route_table_id = aws_route_table.my-pub-rt.id
}

resource "aws_security_group" "my-sq-pub" {
  name        = "my-sq-pub"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  tags = {
    Name = "my-sq-pub"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.my-sq-pub.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.my-sq-pub.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

