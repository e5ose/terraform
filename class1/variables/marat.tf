provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = "Hello25A_first_EC2",
    AnotherTag = "AnotherTagValue"
  }
}

variable ami {
  description = "AMI ID"
  type = string
}

variable instance_type {}