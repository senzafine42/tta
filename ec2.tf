###############################################################
# File: ec2.tf
# Purpose: Define variables and tags for the AWS infrastructure
# Resources: key_pair, security_group, load_balancer, ec2_instances
# Environment: dev
# Caution: This code was created by an orange cat with a single
#          brain cell and should not be used in production
###############################################################

# Key Pair for EC2 instances
# ------------------------------------------------------------

# Generate a new private key locally
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the AWS key pair using the public part
resource "aws_key_pair" "ec2_key" {
  key_name   = "tta-dev-key"
  public_key = tls_private_key.ec2_key.public_key_openssh

  tags = merge(
    {
      Name = "tta-dev-key"
    },
    local.common_tags
  )
}

# Save the private key to a local file
resource "local_file" "ec2_private_key" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = "${path.module}/tta-dev-key.pem"
  file_permission = "0600"
}

# Load balancer for public access
# ------------------------------------------------------------
# AWS Load Balancer
resource "aws_lb" "app_lb" {
  name               = "tta-dev-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true

##############Disabled during troubleshooting##############
  # access_logs {
  # bucket  = aws_s3_bucket.lb_logs.id
  # prefix  = "tta-dev-lb"
  # enabled = true
  # }
##############Disabled during troubleshooting##############

  tags = merge(
    {
      Name = "tta-dev-lb"
    },
    local.common_tags
  )
}

# Least privilege security group for Load Balancer
resource "aws_security_group" "lb_sg" {
  name        = "tta-dev-lb-sg"
  description = "Security group for ALB in dev environment"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "Allow HTTP from within VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      var.public_a_cidr_block,
      var.public_b_cidr_block
    ]
  }

  ingress {
    description = "Allow HTTPS from within VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      var.public_a_cidr_block,
      var.public_b_cidr_block
    ]
  }
  ingress {
    description = "Allow SSH from external restricted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.58.245.171/32"] # Replace with your IP address
  }

  egress {
    description = "Allow all outbound traffic to VPC CIDR"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = merge(
    {
      Name = "tta-dev-lb-sg"
    },
    local.common_tags
  )
}

# Target Group for Load Balancer
resource "aws_lb_target_group" "app_tg" {
  name     = "tta-dev-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.dev.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = merge(
    {
      Name = "tta-dev-tg"
    },
    local.common_tags
  )
}

# Register EC2 instances with the target group
resource "aws_lb_target_group_attachment" "app_tg_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.ec2_public.id
  port             = 80
}

# Create a listener for the load balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Listener troubleshooting powershell command
# terraform state list | Select-String "aws_lb_listener"

##############Disabled during troubleshooting##############
##############Disabled during troubleshooting##############
##############Disabled during troubleshooting##############

# S3 bucket for Load Balancer logs
# ------------------------------------------------------------ 

# resource "aws_s3_bucket" "lb_logs" {
#   bucket = "tta-dev-lb-logs"
#   force_destroy = false

#   tags = merge(
#     {
#         Name = "tta-dev-lb-logs"
#     },
#     local.common_tags
#   )
# }

# resource "aws_s3_bucket_versioning" "lb_logs_versioning" {
#   bucket = aws_s3_bucket.lb_logs.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "lb_logs_encryption" {
#   bucket = aws_s3_bucket.lb_logs.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_s3_bucket_ownership_controls" "lb_logs" {
#   bucket = aws_s3_bucket.lb_logs.id

#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# # Fetch AWS account ID for bucket policy
# data "aws_caller_identity" "current" {}


# resource "aws_s3_bucket_policy" "lb_logs_policy" {
#   bucket = aws_s3_bucket.lb_logs.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid       = "AWSLogDeliveryWrite",
#         Effect    = "Allow",
#         Principal = {
#           Service = "elasticloadbalancing.amazonaws.com"
#         },
#         Action = "s3:PutObject",
#         Resource = "${aws_s3_bucket.lb_logs.arn}/*",
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount" = data.aws_caller_identity.current.account_id
#           }
#         }
#       }
#     ]
#   })
# }

# EC2 Instances
# ------------------------------------------------------------

# Find the latest Amazon Linux 2023 AMI 
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]  # For 64-bit x86
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"]  # Official Amazon AMI owner ID
}



# Public EC2 instance
resource "aws_instance" "ec2_public" {
  ami                   = data.aws_ami.amazon_linux_2023.id # Latest Amazon Linux 2 AMI
  instance_type         = var.ec2_instance_type
  subnet_id             = aws_subnet.public_a.id
  key_name              = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.web_access.id]

  # User data script to install Apache and start the service
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF

  # EBS Volume for the instance
  root_block_device {
    volume_size = 8 # Size in GB
    volume_type = "gp3" # General Purpose SSD
    encrypted = true
    delete_on_termination = true # Delete the volume when the instance is terminated
  }

  tags = merge(
    {
      Name = "tta-dev-ec2-public"
    },
    local.common_tags
  )
}

# Security Group for Public EC2 instances
resource "aws_security_group" "web_access" {
  name        = "allow_http_https"
  description = "Allow HTTP and HTTPS from subnet"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "HTTP from subnet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.public_a_cidr_block]
  }

  ingress {
    description = "HTTPS from subnet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.public_a_cidr_block]
  }

  ingress {
    description = "SSH from external restricted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.58.245.171/32"] # Replace with your IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_a_cidr_block]
  }

  tags = {
    Name = "tta-web-sg"
  }
}

# Private EC2 instance
resource "aws_instance" "ec2_private" {
  ami                   = data.aws_ami.amazon_linux_2023.id # Latest Amazon Linux 2 AMI
  instance_type         = var.ec2_instance_type
  subnet_id             = aws_subnet.priv_a.id
  key_name              = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  # EBS Volume for the instance
  root_block_device {
    volume_size = 8 # Size in GB
    volume_type = "gp3" # General Purpose SSD
    encrypted = true
    delete_on_termination = true # Delete the volume when the instance is terminated
  }
  
  tags = merge(
    {
      Name = "tta-dev-ec2-private"
    },
    local.common_tags
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {

  tags = merge(
    {
      Name = "tta-dev-nat-eip"
    },
    local.common_tags
  )
}

# NAT Gateway for Public Subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(
    {
      Name = "tta-dev-nat-gateway"
    },
    local.common_tags
  )
}

# Security Group for Private EC2 instances
resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh"
  description = "Allow SSH from VPC CIDR"
  vpc_id      = aws_vpc.dev.id  

  ingress {
    description = "SSH from VPC CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = merge(
    {
      Name = "ssh-access"
    },
    local.common_tags
  )
}