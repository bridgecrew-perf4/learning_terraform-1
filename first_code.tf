# Defining provider type AWS
provider "aws" {
  profile   = "default"
  region    = "us-east-1"
}

resource "aws_s3_bucket" "first-bucket" {
  bucket    = "romell-terraform-course-20200115"
  acl       = "private"
}
