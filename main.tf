# main.tf

provider "aws" {
  region = var.aws_region
}

# Підключаємо модуль S3 та DynamoDB
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.s3_bucket_name
  table_name  = var.dynamodb_table_name
}

# Підключаємо модуль для VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = var.vpc_name
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
}

# Підключаємо модуль ECR
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.ecr_repository_name
}