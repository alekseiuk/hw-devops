# main.tf

provider "aws" {
  region = "eu-central-1"
}

# Підключаємо модуль S3 та DynamoDB
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "terraform-state-bucket-in-0574"
  table_name  = "terraform-locks"
}

# Підключаємо модуль для VPC
module "vpc" {
  source              = "./modules/vpc"           # Шлях до модуля VPC
  vpc_cidr_block      = "10.0.0.0/16"             # CIDR блок для VPC
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]        # Публічні підмережі
  private_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]         # Приватні підмережі
  availability_zones  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]            # Зони доступності
  vpc_name            = "lesson-5-vpc"              # Ім'я VPC
}

# Підключаємо модуль ECR
module "ecr" {
  source          = "./modules/ecr"
  repository_name = "lesson-5-ecr"
}