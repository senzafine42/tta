###############################################################
# File: variables.tf
# Purpose: Define variables and tags for the AWS infrastructure
# Resources: aws_vpc
# Environment: dev
# Caution: This code was created by an orange cat with a single
#          brain cell and should not be used in production
###############################################################

# VPC and Subnet Variables
# ------------------------------------------------------------

# Set the AWS region
variable "aws_region" {
    description = "The AWS region to deploy resources in"
    type        = string
    default     = "us-east-2"
}

# Set the availability zones for the VPC and subnets
variable "aws_az_a" {
    description = "The AWS availablity zone"
    type        = string
    default     = "us-east-2a"
}

variable "aws_az_b" {
    description = "The AWS availablity zone"
    type        = string
    default     = "us-east-2b"
}

# Set the CIDR block for the VPC and subnets
variable "vpc_cidr_block" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "public_a_cidr_block" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.1.0/27"
}

variable "public_b_cidr_block" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.2.0/27"
}

variable "priv_a_cidr_block" {
    description = "The CIDR block for the VPC"
    type        = string
    default     = "10.0.3.0/27"
}

# EC2 Instance Variables
# ------------------------------------------------------------

# Instance type chosen for cost and performance
variable "ec2_instance_type" {
    description = "The type of EC2 instance to launch"
    type        = string
    default     = "t3a.micro"
}

# key pair name for accessing the instance 
variable "ec2_key_name" {
    description = "The name of the key pair to use for SSH access"
    type        = string
    default     = "my-key-pair"
}

# S3 Bucket Variables
# ------------------------------------------------------------
variable "lb_logs_prefix" {
  default = "alb-access-logs"
}


# Tags 
# ------------------------------------------------------------

locals {
  common_tags = {
    Environment = "dev"
    Project     = "tta"
    ManagedBy   = "Terraform"
  }
}