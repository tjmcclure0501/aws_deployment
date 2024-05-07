output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.my_vpc.id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]
}

output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.my_ec2_instance.id
}

output "ec2_instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.my_ec2_instance.public_ip
}

output "ec2_instance_private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.my_ec2_instance.private_ip
}

output "rds_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.mydb.endpoint
}

output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.mydb.id
}

output "security_group_ec2_id" {
  description = "The ID of the EC2 security group"
  value       = aws_security_group.my_ec2_security_group.id
}

output "security_group_rds_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.mydb_security_group.id
}
