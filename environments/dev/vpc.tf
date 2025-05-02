###############################################################
# File: vpc.tf
# Purpose: Define Define the Cloud provider, core VPC and CIDR
# Resources: aws_vpc
# Environment: dev
# Caution: This code was created by an orange cat with a single
# brain cell and should not be used in production
#
# Terraform Technical Assignment (TTA)
# Create VPC vpc.tf (VPC, subnets, route tables, NAT/IGW)
# - Public subnet            
# - Private subnet
#
# EC2 instance ec2.tf (EC2 instance, security groups, IAM roles)
# - Public facing
# - security group
# - Private facing (can talk to public instance)
# - security group
#
# Storage s3.terraform (S3 bucket, logging, encryption)
#
# Variables variables.tf (input variables, tags)
###############################################################

# VPC
resource "aws_vpc" "dev" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "tta-dev-vpc"
    },
    local.common_tags
  )
}

# Public Subnet (/24 = 251 IPs)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.public_a_cidr_block
  availability_zone       = var.aws_az_a
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "tta-public-a-subnet"
    },
    local.common_tags
  )
}

# Public Subnet (/24 = 27 IPs)
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.public_b_cidr_block
  availability_zone       = var.aws_az_b
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "tta-public-b-subnet"
    },
    local.common_tags
  )
}

# Private Subnet (/24 = 27 IPs)
resource "aws_subnet" "priv_a" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = var.priv_a_cidr_block
  availability_zone = var.aws_az_a

  tags = merge(
    {
      Name = "tta-private-a-subnet"
    },
    local.common_tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev.id

  tags = merge(
    {
      Name = "tta-dev-igw"
    },
    local.common_tags
  )
}

# Route Table
resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = "tta-public-a-route-table"
    },
    local.common_tags
  )
}

resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = "tta-public-b-route-table"
    },
    local.common_tags
  )
}

resource "aws_route_table" "priv_a" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = "tta-priv-a-route-table"
    },
    local.common_tags
  )
}

# Route Table Association
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_b.id
}

resource "aws_route_table_association" "priv_a" {
  subnet_id      = aws_subnet.priv_a.id
  route_table_id = aws_route_table.priv_a.id
}