resource "aws_security_group" "terraform-sg" {
  name        = "terraform-sg"
  description = "SSH security group for default CIDR"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["172.31.0.0/16"]
  }
}