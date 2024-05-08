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
  map_public_ip_on_launch = true
  tags = {
    Name = "cdc"
  }
}

resource "aws_subnet" "my_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "cdc"
  }
}

resource "aws_security_group" "my_ec2_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  name        = "my_ec2_security_group"
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
  vpc_security_group_ids = [aws_security_group.my_ec2_security_group.id]
  key_name      = "cdc_keypair"
  depends_on = [aws_security_group.my_ec2_security_group]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y postgresql
              cat <<'END' > /home/ec2-user/contract.sql
              CREATE TABLE contract (
                contract_id SERIAL PRIMARY KEY,
                start_date DATE NOT NULL,
                end_date DATE,
                status VARCHAR(100),
                party_details TEXT
              );
              END
              cat <<'END' > /home/ec2-user/insert_contract.sql
              INSERT INTO contract (start_date, end_date, status, party_details) VALUES
              ('2022-01-01', '2023-01-01', 'Active', 'Contract for Project X'),
              ('2022-02-01', NULL, 'Ongoing', 'Open-ended contract for services');
              END
              cat <<'END' > /home/ec2-user/product.sql
              CREATE TABLE product (
                id SERIAL PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                description TEXT,
                nav NUMERIC(10, 2),  -- NAV: Net Asset Value
                total_assets NUMERIC(15, 2), -- Total assets under management
                inception_date DATE,
                contract_id INTEGER REFERENCES contract(contract_id) ON DELETE SET NULL
              );
              END
              cat <<'END' > /home/ec2-user/insert_product.sql
              INSERT INTO product (name, description, nav, total_assets, inception_date, contract_id) VALUES
              ('Fund A', 'A mutual fund focused on equities.', 22.50, 15000000.00, '2021-01-01', 1),
              ('Fund B', 'A mutual fund focused on bonds.', 14.75, 8000000.00, '2021-01-01', 2);
              END
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

  name        = "mydb_security_group"
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
  parameter_group_name = "postgres-16"

  db_subnet_group_name   = aws_db_subnet_group.mydb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.mydb_security_group.id]

  skip_final_snapshot = true

  tags = {
    Name = "cdc"
  }
}
