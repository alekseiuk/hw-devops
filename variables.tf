variable "aws_region" {
  description = "AWS регіон для розгортання інфраструктури"
  type        = string
  default     = "eu-central-1"
}

# --- Змінні для VPC ---
variable "vpc_name" {
  description = "Ім'я VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
}

variable "public_subnets" {
  description = "Список CIDR блоків для публічних підмереж"
  type        = list(string)
}

variable "private_subnets" {
  description = "Список CIDR блоків для приватних підмереж"
  type        = list(string)
}

# --- Змінні для ECR ---
variable "ecr_repository_name" {
  description = "Назва для ECR репозиторію"
  type        = string
}

# --- Змінні для EKS ---
variable "eks_cluster_name" {
  description = "Назва кластера EKS"
  type        = string
}

variable "eks_cluster_version" {
  description = "Версія Kubernetes для кластера EKS"
  type        = string
  default     = "1.36"
}

variable "eks_instance_type" {
  description = "Тип EC2 інстансу для Worker Nodes"
  type        = string
}

variable "eks_desired_size" {
  description = "Бажана кількість Worker Nodes"
  type        = number
}

variable "eks_max_size" {
  description = "Максимальна кількість Worker Nodes"
  type        = number
}

variable "eks_min_size" {
  description = "Мінімальна кількість Worker Nodes"
  type        = number
}

variable "allowed_api_ips" {
  description = "Список IP-адрес (CIDR), яким дозволено доступ до EKS API"
  type        = list(string)
}

# --- Змінні для Argo CD ---
variable "argocd_app_repo_url" {
  description = "URL Git-репозиторію з Helm-чартом застосунку"
  type        = string
}

variable "argocd_app_target_revision" {
  description = "Гілка або тег у репозиторії для Argo CD"
  type        = string
  default     = "main"
}


# --- Змінні для RDS / AURORA ---
variable "db_identifier" {
  description = "Ідентифікатор інстансу або кластера бази даних"
  type        = string
}

variable "use_aurora" {
  description = "Чи використовувати Aurora кластер замість стандартного RDS"
  type        = bool
  default     = false
}

# --- Налаштування Aurora ---
variable "aurora_replica_count" {
  description = "Кількість Read Replicas для кластера Aurora"
  type        = number
  default     = 1
}

variable "db_engine_aurora" {
  description = "Тип рушія для Aurora"
  type        = string
  default     = "aurora-postgresql"
}

variable "db_engine_version_aurora" {
  description = "Версія рушія для Aurora"
  type        = string
  default     = "15.3"
}

variable "db_parameter_group_aurora" {
  description = "Parameter Group Family для Aurora"
  type        = string
  default     = "aurora-postgresql15"
}

# --- Налаштування Standard RDS ---
variable "db_engine_rds" {
  description = "Тип рушія для стандартного RDS"
  type        = string
  default     = "postgres"
}

variable "db_engine_version_rds" {
  description = "Версія рушія для стандартного RDS"
  type        = string
  default     = "17.10"
}

variable "db_parameter_group_rds" {
  description = "Parameter Group Family для стандартного RDS"
  type        = string
  default     = "postgres17"
}

variable "db_multi_az" {
  description = "Увімкнути Multi-AZ для стандартного RDS"
  type        = bool
  default     = true
}

variable "db_allocated_storage" {
  description = "Об'єм пам'яті (ГБ) для стандартного RDS"
  type        = number
  default     = 20
}

# --- Спільні налаштування баз даних ---
variable "db_instance_class" {
  description = "Тип інстансу бази даних"
  type        = string
  default     = "db.t3.medium"
}

variable "db_name" {
  description = "Назва бази даних"
  type        = string
}

variable "db_username" {
  description = "Ім'я користувача-адміністратора бази даних"
  type        = string
  default     = "postgres"
}

variable "db_backup_retention_period" {
  description = "Кількість днів для зберігання бекапів"
  type        = number
  default     = 7
}

variable "db_parameters" {
  description = "Додаткові параметри для бази даних"
  type        = map(string)
  default = {
    max_connections            = "200"
    log_min_duration_statement = "500"
    log_statement              = "all"
    work_mem                   = "4096"
  }
}