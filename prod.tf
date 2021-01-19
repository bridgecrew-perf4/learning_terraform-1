# ====================================

# Defining provider type AWS
provider "aws" {
  profile   = "default"
  region    = "us-east-1"
}

# ====================================

# Creating a sample S3 bucket
resource "aws_s3_bucket" "prod_first_bucket" {
  bucket    = "romell-terraform-course-20200115"
  acl       = "private"
}

# ====================================

# Utilizing the default VPC in AWS
resource "aws_default_vpc" "prod_vpc" {}

# ====================================

# Creating subnets
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    "Availability" = "1"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-1b"
  
  tags = {
    "Availability" = "2"
  }
}

# ====================================

# Creating the security group for our web server
resource "aws_security_group" "prod_security_group" {
  name          = "terraform_prod_web_sg"
  description   = "Allow HTTP and HTTPS ports inbounds and everything outbound"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Inbound rule on port 80"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Inbound rule on port 80"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Outbound rule on any IP address"
  }

  tags = {
    "Terraform" = "true"
    "Course"    = "Learning Basics"
  }
}

# ====================================

# # Creating an aws instance NGNIX
# resource "aws_instance" "prod_web" {
#   count = 2

#   ami                     = "ami-0592a8932e5a2fb0e"
#   instance_type           = "t2.nano"
#   vpc_security_group_ids  = [ aws_security_group.prod_security_group.id ]

#   tags = {
#     "Name" = "Terraform Nginx example"
#   }
# }

# # ====================================

# # Creating Elastic IP Association
# resource "aws_eip_association" "prod_web_association" {
#   instance_id   = aws_instance.prod_web.0.id
#   allocation_id = aws_eip.prod_eip.id
# }

# ====================================

# Creating Elastic IP
resource "aws_eip" "prod_eip" {
  tags = {
    "elasticIP" = true
  }
}

# ====================================

# Creating ELB

resource "aws_elb" "prod_web_lb" {
  name            = "prod-web-lb"
  # instances       = aws_instance.prod_web.*.id
  subnets         = [ aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id ]
  security_groups = [ aws_security_group.prod_security_group.id ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = {
    "Name" = "prod-web-lb"
  }
}

# ====================================

resource "aws_launch_template" "prod_web" {
  name_prefix   = "prod-web"
  image_id      = "ami-0592a8932e5a2fb0e"
  instance_type = "t2.micro"

  tags = {
    "Name" = "Launch Template"
  }
}

resource "aws_autoscaling_group" "prod_web" {
  availability_zones  = ["us-east-1d", "us-east-1b"]
  vpc_zone_identifier = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.prod_web.id
    version = "$Latest"
  }
  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }
}

# ====================================

# Create a new load balancer attachment
resource "aws_autoscaling_attachment" "prod_web" {
  autoscaling_group_name = aws_autoscaling_group.prod_web.id
  elb                    = aws_elb.prod_web_lb.id
}

# ====================================
