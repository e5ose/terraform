provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0779caf41f9ba54f0"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.terraform-sg.id]

  tags = {
    Name = "Hello25A_first_EC2",
    AnotherTag = "AnotherTagValue"
  }
}

###
# Create a security group allowing port 22 from "172.31.0.0/16"
# - name: terraform-sg
# - description: SSH security group for default CIDR
