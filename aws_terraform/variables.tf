variable "region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "List of CIDR blocks for the subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for the subnets."
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "db_instance_type" {
  description = "The instance type for the RDS database."
  type        = string
  default     = "db.t3.micro"
}

variable "ec2_instance_type" {
  description = "The instance type for the EC2 instance."
  type        = string
  default     = "t2.micro"
}

variable "postgres_version" {
  description = "The version of PostgreSQL for the RDS instance."
  type        = string
  default     = "13.3"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance."
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "db_allocated_storage" {
  description = "The allocated storage size for the RDS instance in GB."
  type        = number
  default     = 20
}

variable "db_username" {
  description = "The username for the RDS database."
  type        = string
  default     = "myusername"
}

variable "db_password" {
  description = "The password for the RDS database."
  type        = string
  default     = "mypassword"
}

variable "db_name" {
  description = "The name of the RDS database."
  type        = string
  default     = "cdc"
}