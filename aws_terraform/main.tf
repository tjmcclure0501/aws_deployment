terraform {
  required_version = ">= 0.12"  # Specify the Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"  # Specify the provider version
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "cdc"
  }
}

resource "aws_subnet" "my_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidrs[0]
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "cdc"
  }
}

resource "aws_subnet" "my_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidrs[1]
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "cdc"
  }
}

resource "aws_security_group" "my_ec2_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  name        = "myec2-security-group"
  description = "Allow SSH and ICMP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cdc"
  }
}

resource "aws_instance" "my_ec2_instance" {
  ami           = var.ami_id
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.my_subnet_1.id
  security_groups = [aws_security_group.my_ec2_security_group.name]
  key_name      = aws_key_pair.cdc_keypair.cdc_keypair

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y postgresql
              EOF

  tags = {
    Name = "MyEC2Instance"
  }
}

resource "aws_db_subnet_group" "mydb_subnet_group" {
  name       = "mydb-subnet-group"
  subnet_ids = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]

  tags = {
    Name = "cdc"
  }
}

resource "aws_security_group" "mydb_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  name        = "mydb-security-group"
  description = "Allow PostgreSQL"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cdc"
  }
}

resource "aws_db_instance" "mydb" {
  allocated_storage    = var.db_allocated_storage
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = var.postgres_version
  instance_class       = var.db_instance_type
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres13"

  db_subnet_group_name   = aws_db_subnet_group.mydb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.mydb_security_group.id]

  skip_final_snapshot = true

  tags = {
    Name = "cdc"
  }
}
