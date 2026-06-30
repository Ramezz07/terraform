terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "kubeadm-master" {
  ami                    = "ami-07a00cf47dbbc844c"
  instance_type          = "t3.large"
  key_name               = "master"
  vpc_security_group_ids = ["sg-08ab57ef6bfe52cd0"]
  subnet_id              = "subnet-035c410a1f1692392"

  associate_public_ip_address = true

  root_block_device {
    volume_size = 30 # Size in GB
    volume_type = "gp3"
  }
  tags = {
    Name = "kubeadm-master"
  }
}
