###############################################################
# File: provider.tf
# Purpose: Define variables and tags for the AWS infrastructure
# Resources: provider "aws"
# Environment: dev
# Caution: This code was created by an orange cat with a single
#          brain cell and should not be used in production
###############################################################

provider "aws" {
  region = var.aws_region
}