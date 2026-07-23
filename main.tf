# main.tf

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "dev"
      ManagedBy   = "Terraform"
      Project     = "EKS-Demo"
    }
  }
}

# Отримуємо список усіх доступних AZ у поточному регіоні
data "aws_availability_zones" "available" {
  state = "available"
}

# Підключаємо модуль для VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = var.vpc_name
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  # Беремо перші 3 доступні зони (від індексу 0 до 3)
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}

# Підключаємо модуль ECR
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.ecr_repository_name
}

# Підключаємо модуль EKS
module "eks" {
  source          = "./modules/eks"          
  cluster_name    = "eks-cluster-demo"            # Назва кластера
  cluster_version    = "1.36"
  # Для кластера передаємо об'єднаний список усіх підмереж
  cluster_subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  
  # Для нод передаємо виключно приватні підмережі
  node_subnet_ids    = module.vpc.private_subnets
  
  instance_type      = var.eks_instance_type
  desired_size       = var.eks_desired_size
  max_size           = var.eks_max_size
  min_size           = var.eks_min_size

  allowed_api_ips    = var.allowed_api_ips
}