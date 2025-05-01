###############################################################
# File: output.tf
# Purpose: Define variables and tags for the AWS infrastructure
# Resources: variables, output values
# Environment: dev
# Caution: This code was created by an orange cat with a single
#          brain cell and should not be used in production
###############################################################

output "vpc_id"{
  description = "The ID of the VPC"
  value       = aws_vpc.dev.id
}

output "public_subnet_a_id" {
  description = "ID of public subnet A"
  value       = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  description = "ID of public subnet B"
  value       = aws_subnet.public_b.id
}

output "private_subnet_a_id" {
  description = "ID of private subnet A"
  value       = aws_subnet.priv_a.id
}