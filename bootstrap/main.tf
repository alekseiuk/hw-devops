provider "aws" {
  region = var.aws_region
}

module "s3_backend" {
  source      = "../modules/s3-backend"
  bucket_name = var.s3_bucket_name
}