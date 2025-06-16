provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "wordpress_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "wordpress-vpc"
  }
}

resource "aws_internet_gateway" "wordpress_igw" {
  vpc_id = aws_vpc.wordpress_vpc.id

  tags = {
    Name = "wordpress_igw"
  }
}

resource "aws_subnet" "public" {
    count                = 3
    vpc_id               = aws_vpc.wordpress_vpc.id 
    cidr_block           = var.public_subnets[count.index]
    availability_zone    = "us-east-1${["a", "b", "c"][count.index]}"
    # map_public_ip_on_launch = true 

    tags = {
        Name = "wordpress_public-${count.index + 1}"
    }
}

resource "aws_route_table" "wordpress_rt" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress_igw.id
  }

  tags = {
    Name = "wordpress-rt"
  }
}

resource "aws_route_table_association" "public_association" {
    count = 3
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.wordpress_rt.id
}

resource "aws_security_group" "wordpress_sg" {
    name = "wordpress_sg"
    description = "Allow HTTP, HTTPS, SSH"
    vpc_id = aws_vpc.wordpress_vpc.id

    dynamic "ingress" {
      for_each = var.ingress_ports
      content {
        from_port = ingress.value
        to_port   = ingress.value
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "wordpress=sg"
    }
}

resource "aws_security_group" "rds_sg" {
    name = "rds-sg"
    description = "Allow MySQL from wordpress SG"
    vpc_id = aws_vpc.wordpress_vpc.id

    ingress {
        from_port = 3306
        to_port   = 3306
        protocol  = "tcp"
        security_groups = [aws_security_group.wordpress_sg.id]  
    } 

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
     tags = {
        Name = "rds=sg"
     }
}

resource "aws_key_pair" "ssh_key" {
  key_name = "wordpress"
  public_key = file("/Users/edgar/wordpress.pub")
}

resource "aws_instance" "wordpress_ec2" {
    ami       = var.ami
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public[0].id
    vpc_security_group_ids = [aws_security_group.wordpress_sg.id]
    key_name = aws_key_pair.ssh_key.key_name
    associate_public_ip_address = true



    user_data = file("wordpress.sh") # Script to install wordpress in the cloud

    tags = {
        Name = "wordpress-ec2"
   }
}

resource "aws_db_subnet_group" "mysql_subnet_group" {
    name = "mysql-subnet-group"
    subnet_ids = aws_subnet.private[*].id

    tags = {
        Name = "mysql1-subnet-group"
    }
}

resource "aws_db_instance" "mysql" {
    identifier = "mysql"
    allocated_storage = 20
    engine = "mysql"
    engine_version = "8.4.3"
    instance_class = "db.t3.micro"
    username = var.db_username
    password = var.db_password
    db_subnet_group_name    = aws_db_subnet_group.mysql_subnet_group.name
    vpc_security_group_ids = [aws_security_group.rds_sg.id]
    skip_final_snapshot = true
    publicly_accessible = false

    tags = {
        Name = "mysql"
    }
}

output "wordpress_public_ip" {
    value = aws_instance.wordpress_ec2.public_ip 
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = "us-east-1${["a", "b", "c"][count.index]}"

  tags = {
    Name = "wordpress-private-${count.index + 1}"
  }
}