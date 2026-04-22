provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "example" {
  bucket = "paul-test-bucket-1234567890"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
