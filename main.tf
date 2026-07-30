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
  source          = "./modules/vpc"
  vpc_name        = var.vpc_name
  vpc_cidr_block  = var.vpc_cidr_block
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
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
  cluster_name    = var.eks_cluster_name # Назва кластера
  cluster_version = var.eks_cluster_version
  # Для кластера передаємо об'єднаний список усіх підмереж
  cluster_subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)

  # Для нод передаємо виключно приватні підмережі
  node_subnet_ids = module.vpc.private_subnets

  instance_type = var.eks_instance_type
  desired_size  = var.eks_desired_size
  max_size      = var.eks_max_size
  min_size      = var.eks_min_size

  allowed_api_ips = var.allowed_api_ips
}

# КОНФІГУРАЦІЯ ПРОВАЙДЕРІВ
provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # Передаємо аргументи для AWS CLI, щоб він згенерував токен у реальному часі
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.eks_cluster_name,
      "--region",
      var.aws_region
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.eks_cluster_name,
        "--region",
        var.aws_region
      ]
    }
  }
}

# Підключаємо модуль JENKINS
module "jenkins" {
  source             = "./modules/jenkins"
  cluster_name       = module.eks.eks_cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider_url  = module.eks.oidc_provider_url
  ecr_repository_arn = module.ecr.repository_arn

  depends_on = [module.eks]
}

# Підключаємо модуль ARGO CD
module "argo_cd" {
  source              = "./modules/argo_cd"
  app_repo_url        = var.argocd_app_repo_url
  app_target_revision = var.argocd_app_target_revision
  depends_on          = [module.eks]
}

# Підключаємо модуль RDS
module "rds" {
  source = "./modules/rds"

  name       = var.db_identifier
  use_aurora = var.use_aurora

  # --- Налаштування виключно для Aurora ---
  aurora_replica_count          = var.aurora_replica_count
  engine_cluster                = var.db_engine_aurora
  engine_version_cluster        = var.db_engine_version_aurora
  parameter_group_family_aurora = var.db_parameter_group_aurora

  # --- Налаштування виключно для Standard RDS ---
  engine                     = var.db_engine_rds
  engine_version             = var.db_engine_version_rds
  parameter_group_family_rds = var.db_parameter_group_rds
  multi_az                   = var.db_multi_az
  allocated_storage          = var.db_allocated_storage

  # --- Спільні налаштування (Common) ---
  instance_class = var.db_instance_class
  db_name        = var.db_name
  username       = var.db_username

  # --- Безпека та Мережа ---
  vpc_id              = module.vpc.vpc_id
  subnet_private_ids  = module.vpc.private_subnets
  subnet_public_ids   = module.vpc.public_subnets
  publicly_accessible = false

  backup_retention_period = var.db_backup_retention_period
  parameters              = var.db_parameters

  tags = {
    Environment = "dev"
    Project     = var.db_name
  }
}