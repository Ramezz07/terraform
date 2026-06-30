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

resource "aws_instance" "ubuntu" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"
  key_name      = "master"
  subnet_id = "subnet-02f60aaaeefe5b553"
  security_groups = ["sg-032bf2e821af94e37"]
  

  associate_public_ip_address = true

  root_block_device{
    volume_type = "gp2"
    volume_size = 30
  }
  tags = {
    Name = "ubuntu"
  }
}