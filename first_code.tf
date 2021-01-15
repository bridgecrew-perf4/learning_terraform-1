# Defining provider type AWS
provider "aws" {
  profile   = "default"
  region    = "us-east-1"
}

resource "aws_s3_bucket" "first-bucket" {
  bucket    = "romell_test_terraform_01"
  acl       = "private"
}