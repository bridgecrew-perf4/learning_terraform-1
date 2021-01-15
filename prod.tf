# Defining provider type AWS
provider "aws" {
  profile   = "default"
  region    = "us-east-1"
}

# Creting a sample S3 bucket
resource "aws_s3_bucket" "prod_first_bucket" {
  bucket    = "romell-terraform-course-20200115"
  acl       = "private"
}

# Utilizing the default VPC in AWS
resource "aws_default_vpc" "prod_vpc" {

}

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