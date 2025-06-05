provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-02457590d33d576c3"
  instance_type = "t3.micro"

  tags = {
    Name = "Hello25A_first_EC2"
  }
}
