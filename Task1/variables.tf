variable "vpc_cidr" { default = "10.0.0.0/16"}
variable "public_subnets" { default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]}
variable "private_subnets" { default = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]}

variable "ingress_ports" {
    default = [22, 80, 443]
}  

variable "ami" {
    # Latest Amazon Linux 2 AMI in us-east-1
    default = "ami-0c2b8ca1dad447f8a"
}
  
variable "db_username" { default = "edgardo" }
variable "db_password" { default = "bakladjan29" }


